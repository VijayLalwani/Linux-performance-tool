#!/bin/sh

#check root
user_id=`whoami`
if [[ "$user_id" != "root" ]]
then
    echo "$0: please run this script as root user."
    exit
fi

# install earlyoom if not in the system
if [[ $(pacman -Q earlyoom | grep earlyoom*) -ne 0 ]]; then
    pacman -S earlyoom --noconfirm
fi

# main script:
main() {

  # make sure `set -u` doesn't cause 'case "1$"' to throw errors below
  { [ "$#" -eq "0" ] && set -- ""; } > /dev/null 2>&1

  case "$1" in
    start)
        systemctl start earlyoom
        ;;
    stop)
        systemctl stop earlyoom
        ;;
    restart)
        systemctl restart earlyoom
        ;;
    help)
        Help
        ;;
    *)
        echo "Usage: $(basename "$0") (start|stop|restart|help)" 
        exit 1
        ;;
  esac
}

Help()
{
   # Display Help
   echo
   echo "Syntax: $(basename "$0") (start|stop|restart|help)"
   echo "options:"
   echo "start      Starts the earlyoom service."
   echo "stop       Terminates the earlyoom service."
   echo "restart    Restarts the earlyoom service."
   echo "help       Prints this help screen."
   echo
}

main "$@"