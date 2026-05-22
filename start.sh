#!/bin/bash

trap "./scripts/cleanup.sh" EXIT

./scripts/backup.sh
./bin/inotify | ./scripts/output.sh