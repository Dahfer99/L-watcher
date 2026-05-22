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

if [[ "$event" == "ATTRIB" ]]; then
        
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