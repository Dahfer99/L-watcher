#!/bin/bash

target="$1"

# AUSEARCH FAIL
# DEBUG — remove after fixing
# echo "DEBUG: target=$target" >&2
# raw=$() 
# echo "DEBUG: raw=$(echo $raw)" >&2
# echo "DEBUG: raw lines=$(echo $raw | wc -l)" >&2
# echo "DEBUG: after grep auid=$(echo $raw | grep auid= | grep -v 'tty=(none)')">&2
# echo "DEBUG trace: $(whoami)" >&2
# echo "DEBUG: ausearch result:" >&2
# sudo ausearch -k lwatcher -ts recent 2>&1 | tail -20 >&2
# auid=$(sudo ausearch -k lwatcher -ts recent 2>/dev/null \
#     | grep "auid=" \
#     | grep "tty=pts" \
#     | tail -1 \
#     | grep -oP 'auid=\K[0-9]+')

# if [[ -z "$auid" ]] || [[ "$auid" == "4294967295" ]]; then
#     echo "unknown"
#     exit 0
# fi

# username=$(getent passwd "$auid" | cut -d: -f1)
# if [[ -z "$username" ]];then 
#     echo "uid:$auid"
# else 
#     echo "$username"
# fi
# Dead code --- ignore

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