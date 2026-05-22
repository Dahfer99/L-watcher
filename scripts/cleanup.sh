#!/bin/bash

max_days=7

log_file="./logs/session.log"
log_dir="./logs"
backup_dir="./backup"

if [ ! -f "$log_file" ];then
    echo "Error: no current log file found"
    exit 0
fi 

mv "$log_file" "./logs/session_$(date +%Y%m%d)_$(date +%H%M).log"
find "$log_dir" -name "session_*.log" -mtime "+$max_days" -delete
find "$backup_dir" -name "*.tar.gz" -mtime "+$max_days" -delete