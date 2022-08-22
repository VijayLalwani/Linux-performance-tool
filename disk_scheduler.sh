available_disks() 
{
    DISK=$(ls /sys/block)
    echo $DISK
}

available_algorithms() 
{
    ALGO=$(cat /sys/block/sda/queue/scheduler)
    echo $ALGO
}

selected_disk=$1
selected_algorithm=$2
