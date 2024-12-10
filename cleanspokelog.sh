#!/bin/bash

project="/home/ubuntu2/git_clone/hip-vpls"
r1="/spoke1/hipls.log"
r2="/spoke2/hipls.log"
r3="/spoke3/hipls.log"

# Array of log files
log_files=(
    "${project}${r1}"
    "${project}${r2}"
    "${project}${r3}"
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