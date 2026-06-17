#!/bin/bash

RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
PURPLE="\033[35m"
CYAN="\033[36m"
RESET="\033[0m"

log_dir="./logs"
log_file="$log_dir/session.log"

if [ ! -d "$log_dir" ]; then
    mkdir $log_dir
fi

touch $log_file
last_created=""

printf "${RED}%-25s %-15s %-15s %-30s %-15s %-15s %-15s %-15s${RESET}\n" "TIME" "EVENT" "TYPE" "PATH" "NAME" "PERMS" "OWNER" "GROUP"

while IFS=: read event type path name ; do
    time=$(date "+[%a %d %b %H:%M:%S]")

    clean_path="${path#/}"
    # backup_dir_basename=$(basename $path)
    backup_file="./backup/$1/$clean_path/$name"

    if [[ "$type" == "DIRECTORY" ]]; then

        target="$path"
        dir_basename=$(basename "$path")
        backup_file="./backup/$1/$dir_basename" # Actually it's directory but i'm too lazy to change the var's name

    else
        target="$path$name"
    fi

    if [[ "$event" != "DELETED" && "$event" != "MOVED_FROM" ]];then

        perms=$(stat -c "%a" "$target")
        owner=$(stat -c "%U" "$target")
        group=$(stat -c "%G" "$target")
    fi 

    if [[ "$event" == "CREATED" ]]; then

        last_created=$name
        printf "${GREEN}%-25s${RESET}%-15s %-15s %-30s %-15s %-15s %-15s %-15s\n" "$time" "$event" "$type" "$path" "$name" "$perms" "$owner" "$group"
        printf "%-25s %-15s %-15s %-35s %-15s %-15s %-15s %-15s\n" "$time" "$event" "$type" "$path" "$name" "$perms" "$owner" "$group" >> "$log_file"

    elif [[ "$event" == "MODIFIED" ]]; then

        dir_prefix="${clean_path//\//_}"
        diff_dir="./logs/diffs"
        diff_name="${dir_prefix}_${name}_$1.txt"
        diff_file="./logs/diffs/$diff_name"

        if [ ! -d "$diff_dir" ]; then
            mkdir -p $diff_dir
        fi

        if [ -f "$backup_file" ]; then
            diff_output=$(diff "$backup_file" "/${clean_path}/${name}")
            changed=$(echo "$diff_output" | grep -c "^[<>]")

            printf "${GREEN}%-25s${RESET}%-15s %-15s %-30s %-15s %-15s %-15s %-15s %-35s\n" "$time" "$event" "$type" "$path" "$name" "$perms" "$owner" "$group" "[ ${changed} lines changed -> $path$name ]"
            printf "%-25s %-15s %-15s %-35s %-15s %-15s %-15s %-15s %-35s\n" "$time" "$event" "$type" "$path" "$name" "$perms" "$owner" "$group" "[${changed} lines changed -> $path$name]" >>"$log_file"
            printf "%-25s %-35s %-15s \n %s\n\n" "$time" "$path" "$name" "$diff_output" >> "$diff_file"

        else

            printf "${GREEN}%-25s${RESET}%-15s %-15s %-30s %-15s %-15s %-15s %-15s %-25s\n" "$time" "$event" "$type" "$path" "$name" "$perms" "$owner" "$group" "[No backup found]"
            printf "%-25s %-15s %-15s %-35s %-15s %-15s %-15s %-15s\n" "$time" "$event" "$type" "$path" "$name" "$perms" "$owner" "$group" >>"$log_file"
        fi

    elif [[ "$event" == "ATTRIB" ]]; then 
        if [ "$name" == "$last_created" ]; then
            last_created=""
        else 
            printf "${GREEN}%-25s${RESET}%-15s %-15s %-30s %-15s %-15s %-15s %-15s \n" "$time" "$event" "$type" "$path" "$name" "$perms" "$owner" "$group"
            printf "%-25s %-15s %-15s %-35s %-15s %-15s %-15s %-15s\n" "$time" "$event" "$type" "$path" "$name" "$perms" "$owner" "$group" >> "$log_file"
        fi 

    else

        printf "${GREEN}%-25s${RESET}%-15s %-15s %-30s %-15s %-15s %-15s %-15s\n" "$time" "$event" "$type" "$path" "$name" "$perms" "$owner" "$group"
        printf "%-25s %-15s %-15s %-35s %-15s %-15s %-15s %-15s \n" "$time" "$event" "$type" "$path" "$name" "$perms" "$owner" "$group" >> "$log_file"

    fi

done
