user_id=`whoami`
if [[ "$user_id" != "root" ]]
then
    echo "$0: please run this script as root user."
    exit
fi