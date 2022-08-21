#!/bin/sh

#check root
user_id=`whoami`
if [[ "$user_id" != "root" ]]
then
    echo "$0: please run this script as root user."
    exit
fi

# install earlyoom if not in the system
if pacman -Q earlyoom | grep earlyoom ; then
    pacman -S earlyloom --noconfirm
fi

# main script:
_main() {

  # make sure `set -u` doesn't cause 'case "1$"' to throw errors below
  { [ "$#" -eq "0" ] && set -- ""; } > /dev/null 2>&1

  case "$1" in
    "init" | "start")
      systemctl start earlyoom
      ;;
    "end" | "stop")
      systemctl stop earlyoom
      ;;
    "restart" | "restart")
      systemctl restart earlyoom
      ;;
    *)
      echo "Usage: $(basename "$0") (start|stop|restart)" 
      exit 1
      ;;
  esac
}