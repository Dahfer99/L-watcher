#!/bin/bash

max_days=${2:-7}

log_file="./logs/session.log"
log_dir="./logs"
backup_dir="./backup"
diff_dir="./logs/diffs/"
child_backup_dir="./backup/$1/"

if [ ! -f "$log_file" ];then
    echo "Error: no current log file found"
    exit 0
fi 

#auditctl -D -k lwatcher 2>/dev/null
mv "$log_file" "./logs/session_$(date +%Y%m%d)_$(date +%H%M).log"
find "$log_dir" -name "session_*.log" -mtime "+$max_days" -delete
find "$backup_dir" -name "*.tar.gz" -mtime "+$max_days" -delete
find "$diff_dir" -name "*.diff" -mtime "+$max_days" -delete
rm -rf "$child_backup_dir"

remote_backup=$3
if [ -n "$remote_backup" ]; then
    echo "Sending backup to $remote_backup..."
    scp "$log_dir/session_$1.log" "$remote_backup"
    scp "$diff_dir/*_$1.diff" "$remote_backup"
    if [ "$?" -eq 0 ]; then
      echo ""
    else
      echo "copie du log échoué"
    fi

  ssh -i ~/.ssh/lwatch_key "${remote_backup%%:*}" \
    "sed -i '/lwatch_key/d' ~/.ssh/authorized_keys" 2>/dev/null
  rm -f ~/.ssh/lwatch_key
  rm -f ~/.ssh/lwatch_key.pub
fi