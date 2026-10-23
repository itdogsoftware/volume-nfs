#!/bin/sh

function start()
{

    unset gid
    # accept "-G gid" option
    while getopts "G:" opt; do
        case ${opt} in
            G) gid=${OPTARG};;
        esac
    done
    shift $(($OPTIND - 1))

    # prepare /etc/exports
    for i in "$@"; do
        # fsid=0: needed for NFSv4
        echo "$i *(rw,fsid=0,insecure,no_root_squash)" >> /etc/exports
        if [ -v gid ] ; then
            chmod 070 $i
            chgrp $gid $i
        fi
        # move index.html to here
        /bin/cp /tmp/index.html $i/
        chmod 644 $i/index.html
        echo "Serving $i"
    done
  
    # start rpcbind if it is not started yet
    /sbin/rpcinfo 127.0.0.1 > /dev/null; s=$?
    if [ $s -ne 0 ]; then
       echo "Starting rpcbind"
       /sbin/rpcbind -w
    fi

    mount -t nfsd nfds /proc/fs/nfsd

    # -V 3: enable NFSv3
    /usr/sbin/rpc.mountd -V 3 -p 20048

    /usr/sbin/exportfs -r
    # -G 10 to reduce grace time to 10 seconds (the lowest allowed)
    /usr/sbin/rpc.nfsd -G 10 -V 3
    /sbin/rpc.statd --no-notify
    echo "NFS started"

    # --- START LSYNCD SYNC AGENT ---
    # Ensure drop-in config folder exists on the NFS volume
    mkdir -p /exports/lsyncd.d

    if [ -f /etc/lsyncd.conf.lua ]; then
        echo "Starting lsyncd daemon..."
        lsyncd /etc/lsyncd.conf.lua &
    else
        echo "Warning: /etc/lsyncd.conf.lua not found, lsyncd skipped."
    fi
    # ---------------------------------------

}

function stop()
{
    echo "Stopping NFS"

    # Kill lsyncd if running
    kill $(pgrep lsyncd) 2>/dev/null

    /sbin/rpc.nfsd 0
    /usr/sbin/exportfs -au
    /usr/sbin/exportfs -f

    kill $( pidof rpc.mountd )
    umount /proc/fs/nfsd
    echo > /etc/exports
    exit 0
}


trap stop TERM

start "$@"

# Ugly hack to do nothing and wait for SIGTERM
while true; do
    sleep 5
done
