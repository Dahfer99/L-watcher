#!/bin/bash
clear
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
PURPLE="\033[35m"
CYAN="\033[36m"
RESET="\033[0m"

config_path="./config/inotify.config"
time_stamp=$1
backup_dir="./backup/$time_stamp"

if [ ! -d "$backup_dir" ];then
    mkdir -p "$backup_dir"
    if [ "$?" -ne 0 ]; then 
        printf "${RED}Error:${RESET} Impossible de creer le repertoire de sauvegarde"
    fi 
fi

while IFS= read -r line;do

    [[ "$line" == \#* ]] && continue
    [[ -z "$line" ]] && continue
    if [[ ! -e "$line" ]];then
        echo "Warning: $line not found"
        continue
    fi 
    cp -r "$line" "$backup_dir/"
    printf "${BLUE}Watchin:${RESET} %s\n" "$line"
done < "$config_path"

tar -czf "./backup/$time_stamp.tar.gz" -C "./backup" "$time_stamp"
if [ "$?" -ne 0 ]; then 
    printf "${RED}Error:${RESET} La creation de l'archive de sauvegarde a echoue"
fi 