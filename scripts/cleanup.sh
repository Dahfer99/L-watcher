#!/bin/bash

max_days=7

log_file="./logs/session.log"
log_dir="./logs"
backup_dir="./backup"
diff_dir="./logs/diffs/"
child_backup_dir="./backup/$1/"

if [ ! -f "$log_file" ];then
    echo "Error: no current log file found"
    exit 0
fi 

mv "$log_file" "./logs/session_$1.log"
find "$log_dir" -name "session_*.log" -mtime "+$max_days" -delete
find "$backup_dir" -name "*.tar.gz" -mtime "+$max_days" -delete
find "$diff_dir" -name "*.diff" -mtime "+$max_days" -delete
rm -rf "$child_backup_dir"