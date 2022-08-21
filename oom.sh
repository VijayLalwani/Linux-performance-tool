#!/bin/sh
user_id=`whoami`
if [[ "$user_id" != "root" ]]
then
    echo "$0: please run this script as root user."
    exit
fi
# cant just replace if file doesnt have it, cant just add in the end because 
FILE=/etc/systemd/system/user@service.service.d/override.conf
if [ -f "$FILE" ]
then
    sed -i -e '/^ManagedOOMMemoryPressure=/d' -e '/Service/a ManagedOOMMemoryPressure=kill' $FILE
    sed -i -e '/^ManagedOOMMemoryPressureLimit=/d' -e '/Service/a ManagedOOMMemoryPressureLimit=50%' $FILE
else 
    echo "$FILE does not exist."
fi

FILE=/etc/systemd/system/user.slice.d/override.conf
if [ -f "$FILE" ]
then
    sed -i -e '/^ManagedOOMSwap=/d' -e '/Slice/a ManagedOOMSwap=kill' $FILE
else 
    echo "$FILE does not exist."
fi