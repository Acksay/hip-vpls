#!/bin/bash

project="/home/ubuntu2/git_clone/hip-vpls"
r1="/router1/hipls.log"
r2="/router2/hipls.log"
r3="/router3/hipls.log"
r4="/router4/hipls.log"
r5="/router5/hipls.log"
r6="/router6/hipls.log"
r1t="/router1/timefile.txt"
r2t="/router2/timefile.txt"
r3t="/router3/timefile.txt"
r4t="/router4/timefile.txt"
r5t="/router5/timefile.txt"
r6t="/router6/timefile.txt"

# Array of log files
log_files=(
    "${project}${r1}"
    "${project}${r2}"
    "${project}${r3}"
    "${project}${r4}"
    "${project}${r5}"
    "${project}${r6}"
    "${project}${r1t}"
    "${project}${r2t}"
    "${project}${r3t}"
    "${project}${r4t}"
    "${project}${r5t}"
    "${project}${r6t}"
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