#!/bin/bash

target="$1" 

if command -v lsof &>/dev/null; then 
    user=$(lsof $target 2>/dev/null | awk 'NR==2{printf $3}')
    if [[ -n "$user" ]];then 
        echo "$user"
        exit 0
    fi
else 
for pid_dir in /proc/[0-9]*/; do
    pid="${pid_dir%/}"
    pid="${pid##*/}"
    [[ ! -d "${pid_dir}fd" ]] && continue
    for fd in "${pid_dir}fd/"*; do
        link=$(readlink "$fd" 2>/dev/null)
        if [[ "$link" == "$target" ]]; then
            uid=$(awk '/^Uid:/{print $2}' "${pid_dir}status" 2>/dev/null)
            getent passwd "$uid" 2>/dev/null | cut -d: -f1
            exit 0
        fi
    done
done
fi
who | awk '{print $1}' | sort -u | paste -sd ',' -