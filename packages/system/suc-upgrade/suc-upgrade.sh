#!/bin/bash
set -x -e
HOST_DIR="${HOST_DIR:-/host}"

if [ "$FORCE" != "true" ]; then
    if diff /etc/os-release $HOST_DIR/etc/os-release >/dev/null; then
        echo Update to date with
        cat /etc/os-release
        exit 0
    fi
fi

mount --rbind $HOST_DIR/dev /dev
mount --rbind $HOST_DIR/run /run

recovery_mode=false
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --recovery) recovery_mode=true;;
    esac
    shift
done
if [ "$recovery_mode" = true ]; then
    kairos-agent upgrade --recovery --source dir:/
else
    kairos-agent upgrade --source dir:/
fi
nsenter -i -m -t 1 -- reboot
exit 1
