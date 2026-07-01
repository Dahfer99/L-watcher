#!/bin/bash
clear
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
PURPLE="\033[35m"
CYAN="\033[36m"
RESET="\033[0m"

config_path="/etc/lwatcher/inotify.config"
time_stamp=$1
backup_dir="$HOME/lwatcher/backup/$time_stamp"

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
    dir_backup="$backup_dir$line"
    [[ ! -d "$dir_backup" ]] && mkdir -p "$( dirname $dir_backup )"
    cp -r "$line" "$dir_backup"
    printf "${BLUE}Watching:${RESET} %s\n" "$line"
done < "$config_path"

tar -czf "$HOME/lwatcher/backup/$time_stamp.tar.gz" -C "$HOME/lwatcher/backup" "$time_stamp"
if [ "$?" -ne 0 ]; then
    printf "${RED}Error:${RESET} La creation de l'archive de sauvegarde a echoue"
fi

remote_backup=$2
if [ -n "$remote_backup" ]; then
    echo "Sending backup to $remote_backup..."
    scp "$HOME/lwatcher/backup/$time_stamp.tar.gz" "$remote_backup"
    if [ $? -eq 0 ]; then
      echo "Sauvegarde à distance réussi"
    else
      echo "Sauvegarde à distance échoué"
    fi
fi