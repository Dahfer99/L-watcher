#!/bin/bash

session_time=$(date +%Y%m%d_%H%M)

trap "./scripts/cleanup.sh $session_time" EXIT

./scripts/backup.sh $session_time
./bin/inotify | ./scripts/output.sh $session_time