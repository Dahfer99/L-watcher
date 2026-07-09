#!/bin/bash
# max_days=${2:-7}
timestamp="$1"

if [ -z "$2" ];then
  max_days=7
else
  max_days="$2"
fi

log_dir="/var/log/lwatcher"
log_file="$log_dir/session.log"
backup_dir="$HOME/lwatcher/backup"
diff_dir="$log_dir/diffs"
child_backup_dir="$backup_dir/$timestamp/"

if [ ! -f "$log_file" ];then
    echo "Error: no current log file found"
    exit 0
fi 

mv "$log_file" "$log_dir/session_$timestamp.log"
find "$log_dir" -name "session_*.log" -mtime "+$max_days" -delete
find "$backup_dir" -name "*.tar.gz" -mtime "+$max_days" -delete
find "$diff_dir" -name "*.txt" -mtime "+$max_days" -delete
rm -rf "$child_backup_dir"

shopt -s nullglob
matches=("$diff_dir"/*"$timestamp".txt)
shopt -u nullglob


remote_backup=$3
if [ -n "$remote_backup" ]; then
    scp "$log_dir/session_$timestamp.log" "$remote_backup"
    if [ ${#matches[@]} -gt 0 ]; then
      scp "${matches[@]}" "$remote_backup"
    fi

    if [ "$?" -eq 0 ]; then
      echo "copie du log réussi"
    else
      echo "copie du log échoué"
    fi

  ssh -i ~/.ssh/lwatch_key "${remote_backup%%:*}" \
    "sed -i '/lwatch_key/d' ~/.ssh/authorized_keys" 2>/dev/null
  rm -f ~/.ssh/lwatch_key
  rm -f ~/.ssh/lwatch_key.pub
fi