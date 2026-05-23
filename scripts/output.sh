#!/bin/bash

CYAN="\033[36m"
GREEN="\033[32m"
RESET="\033[0m"

log_dir="./logs"
log_file="$log_dir/session.log"

if [ ! -d "$log_dir" ];then 
    mkdir $log_dir
fi 

touch $log_file

printf "${CYAN}%-25s %-15s %-15s %-30s %-15s${RESET}\n" "TIME" "EVENT" "TYPE" "PATH" "NAME"

while IFS=: read event type path name; do 
    time=$(date "+[%a %d %b %H:%M:%S]")

    if [[ "$event" == "MODIFIED" ]]; then
        
        clean_path="${path#/}"
        dir_prefix="${clean_path//\//_}"
        diff_dir="./logs/diffs"

        if [ ! -d "$diff_dir" ]; then
            mkdir -p $diff_dir
        fi

        diff_name="${dir_prefix}_${name}_$1.diff"
        diff_file="./logs/diffs/$diff_name"
        backup_dir_basename=$(basename $path)
        backup_file="./backup/$1/$backup_dir_basename/$name"

        if [ -f "$backup_file" ]; then 
            diff_output=$(diff "$backup_file" "/${clean_path}/${name}")
            changed=$(echo "$diff_output" | grep -c "^[<>]")

            printf "${GREEN}%-25s${RESET}%-15s %-15s %-30s %-15s %-25s\n" "$time" "$event" "$type" "$path" "$name" "[ ${changed} lines changed -> $path$name ]"
            printf "%-25s %-15s %-15s %-35s %-15s %-25s\n" "$time" "$event" "$type" "$path" "$name" "[${changed} lines changed -> $path$name]" >> "$log_file"
            printf "%-25s %-35s %-15s\n %s\n\n" "$time" "$path" "$name" "$diff_output" >> "$diff_file"

        else

            printf "${GREEN}%-25s${RESET}%-15s %-15s %-30s %-15s %-25s\n" "$time" "$event" "$type" "$path" "$name" "[No backup found]"
            printf "%-25s %-15s %-15s %-35s %-15s\n" "$time" "$event" "$type" "$path" "$name" >> "$log_file"    
        fi 


    elif [[ "$event" == "ATTRIB" ]]; then
        
        perms=$(stat -c "%a" "$path/$name")
        owner=$(stat -c "%U" "$path/$name")
        group=$(stat -c "%G" "$path/$name")
        
        printf "${GREEN}%-25s${RESET}%-15s %-15s %-30s %-15s %-15s %-15s %-15s\n" "$time" "$event" "$type" "$path" "$name" "P=$perms" "O=$owner" "G=$group"
        printf "%-25s %-15s %-15s %-35s %-15s %-15s %-15s %-15s\n" "$time" "$event" "$type" "$path" "$name" "P=$perms" "O=$owner" "G=$group" >> "$log_file"
    else
        printf "${GREEN}%-25s${RESET}%-15s %-15s %-30s %-15s\n" "$time" "$event" "$type" "$path" "$name"
        printf "%-25s %-15s %-15s %-35s %-15s\n" "$time" "$event" "$type" "$path" "$name" >> "$log_file"
    fi
done