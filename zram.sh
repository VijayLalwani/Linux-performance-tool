#!/bin/sh
# source: https://github.com/foundObjects/zram-swap
# shellcheck disable=SC2013,SC2039,SC2064

[ "$(id -u)" -eq '0' ] || { echo "This script requires root." && exit 1; }
case "$(readlink /proc/$$/exe)" in */bash) set -euo pipefail ;; *) set -eu ;; esac

# ensure a predictable environment
export PATH=/usr/sbin:/usr/bin:/sbin:/bin
\unalias -a

# parse debug flag early so we can trace user configuration
[ "$#" -gt "0" ] && [ "$1" = "-x" ] && shift && set -x

# set sane defaults, see /etc/default/zram-swap for explanations
zram_fraction="1/2"
zram_algorithm="lz4"
comp_factor=''
zram_fixedsize=''
zram_swap_debug=''

# load user config
[ -f /etc/default/zram-swap ] &&
  . /etc/default/zram-swap

# support a debugging flag in the config file so people don't have to edit the systemd service
# to enable debugging
[ -n "$zram_swap_debug" ] && set -x

# set expected compression ratio based on algorithm -- we'll use this to
# calculate how much uncompressed swap data we expect to fit into our
# target ram allocation.  skip if _
    lzo* | zstd) comp_factor="3" ;;
    lz4) comp_factor="2.5" ;;
    *) comp_factor="2" ;;
  esac
fi

# main script:
main() {
  if ! modprobe zram; then
    err "main: Failed to load zram module, exiting"
    return 1
  fi

  # make sure `set -u` doesn't cause 'case "1$"' to throw errors below
  { [ "$#" -eq "0" ] && set -- ""; } > /dev/null 2>&1

  case "$1" in
    "init" | "start")
      if grep -q zram /proc/swaps; then
        err "main: zram swap already in use, exiting"
        return 1
      fi
      init
      ;;
    "end" | "stop")
      if ! grep -q zram /proc/swaps; then
        err "main: no zram swaps to cleanup, exiting"
        return 1
      fi
      end
      ;;
    "restart")
      echo "not supported yet"
      usage
      exit 1
      ;;
    *)
      usage
      exit 1
      ;;
  esac
}

# initialize swap
init() {
  if [ -n "$zram_fixedsize" ]; then
    if ! regex_match "$_zram_fixedsize" '^[[:digit:]]+(\.[[:digit:]]+)?(G|M)$'; then
      err "init: Invalid size '$zram_fixedsize'. Format sizes like: 100M 250M 1.5G 2G etc."
      exit 1
    fi
    # Use user supplied zram size
    mem="$zram_fixedsize"
  else
    # Calculate memory to use for zram
    totalmem=$(awk '/MemTotal/{print $2}' /proc/meminfo)
    mem=$(calc "$totalmem * $comp_factor * $zram_fraction * 1024")
  fi

  # NOTE: zramctl sometimes fails if we don't wait for the module to settle after loading
  #       we'll retry a couple of times with slightly increasing delays before giving up
  device=''
  for i in $(seq 3); do
    # sleep for "0.1 * $i" seconds rounded to 2 digits
    sleep "$(calc 2 "0.1 * $i")"
    device=$(zramctl -f -s "$mem" -a "$zram_algorithm") || true
    [ -b "$device" ] && break
  done

  if [ -b "$device" ]; then
    # cleanup the device if swap setup fails
    trap "rem_zdev $device" EXIT
    mkswap "$device"
    swapon -d -p 15 "$device"
    trap - EXIT
    return 0
  else
    err "init: Failed to initialize zram device"
    return 1
  fi
}

# end swapping and cleanup
end() {
  ret="0"
  for dev in $(awk '/zram/ {print $1}' /proc/swaps); do
    swapoff "$dev"
    if ! rem_zdev "$dev"; then
      err "end: Failed to remove zram device $dev"
      ret=1
    fi
  done
  return "$ret"
}

# Remove zram device with retry
rem_zdev() {
  if [ ! -b "$1" ]; then
    err "rem_zdev: No zram device '$1' to remove"
    return 1
  fi
  for i in $(seq 3); do
    # sleep for "0.1 * $i" seconds rounded to 2 digits
    sleep "$(calc 2 "0.1 * $i")"
    zramctl -r "$1" || true
    [ -b "$1" ] || break
  done
  if [ -b "$1" ]; then
    err "rem_zdev: Couldn't remove zram device '$1' after 3 attempts"
    return 1
  fi
  return 0
}

# posix substitute for bash pattern matching [[ $foo =~ bar-pattern ]]
# usage: regex_match "$foo" "bar-pattern"
regex_match() { echo "$1" | grep -Eq -- "$2" > /dev/null 2>&1; }

# calculate with variable precision
# usage: calc (int; precision := 0) (str; expr to evaluate)
calc() {
  regex_match "$1" '^[[:digit:]]+$' && { n="$1" && shift; } || n=0
  LC_NUMERIC=C awk "BEGIN{printf \"%.${n}f\", $*}"
}

err() { echo "Err $*" >&2; }
usage() { echo "Usage: $(basename "$0") (start|stop)"; }

main "$@"