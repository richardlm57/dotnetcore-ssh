#!/bin/bash

printf "\n%10s\n" "INOTIFY"
printf "%10s\n" "WATCHER"
printf "%10s  %5s     %s\n" " COUNT " "PID" "CMD"
printf -- "----------------------------------------\n"

IFS=''; # to avoid `read` from interpreting whitespace and keep whole lines
find /proc/*/fd -lname anon_inode:inotify -printf '%hinfo/%f\n' 2>/dev/null | xargs grep -c '^inotify' | sort -n -t: -k2 -r  | while read line; do
    watcher_count=$(echo $line | sed -e 's/.*://')
    pid=$(echo $line | sed -e 's/\/proc\/\([0-9]*\)\/.*/\1/')
    cmdline=$(ps --columns 120 -o command -h -p $pid) 
    printf "%8d  %7d  %s\n" "$watcher_count" "$pid" "$cmdline"
done
