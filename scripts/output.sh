#!/bin/bash

CYAN="\033[36m"
GREY="\033[90m"
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
    printf "${GREY}%-25s${RESET}%-15s %-15s %-30s %-15s\n" "$time" "$event" "$type" "$path" "$name"
    printf "%-25s %-15s %-15s %-35s %-15s\n" "$time" "$event" "$type" "$path" "$name" >> "$log_file"
done