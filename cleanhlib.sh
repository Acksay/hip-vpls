#!/bin/bash

project="/home/ubuntu2/git_clone/hip-vpls"
r1="/router1/hipls.log"
r2="/router2/hipls.log"
r3="/router3/hipls.log"
r4="/router4/hipls.log"
r5="/router5/hipls.log"
r6="/router6/hipls.log"

# Array of log files
log_files=(
    "${project}${r1}"
    "${project}${r2}"
    "${project}${r3}"
    "${project}${r4}"
    "${project}${r5}"
    "${project}${r6}"
)

# Clear the content of each log file
for file in "${log_files[@]}"; do
    if [ -f "$file" ]; then
        sudo bash -c "truncate -s 0 $file"
        echo "Cleared: $file"
    else
        echo "File not found: $file"
    fi
done

echo "Log files cleared."