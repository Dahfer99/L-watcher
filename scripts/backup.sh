#!/bin/bash

config_path="./config/inotify.config"
time_stamp=$1
backup_dir="./backup/$time_stamp"

if [ ! -d "$backup_dir" ];then
    mkdir -p "$backup_dir"
    ls "$backup_dir"
fi

while IFS= read -r line;do

    [[ "$line" == \#* ]] && continue
    [[ -z "$line" ]] && continue
    if [[ ! -e "$line" ]];then
        echo "Warning: $line not found"
        continue
    fi 
    cp -r "$line" "$backup_dir/"

    echo $line
done < "$config_path"

tar -czf "./backup/$time_stamp.tar.gz" -C "./backup" "$time_stamp"
rm -rf "$backup_dir"