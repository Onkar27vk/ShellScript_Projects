#!/bin/bash

LOG_DIR="$HOME/shell-labs/lab2/logs"
DAYS=7

echo "Scanning directory: $LOG_DIR"
echo "Looking for files older than $DAYS days..."

FILES=$(find "$LOG_DIR" -type f -name "*.log" -mtime +"$DAYS")

if [[ -z "$FILES" ]]; then
    echo "No old log files found."
    exit 0
fi

echo "Files found:"
echo "$FILES"

echo "Deleting files..."

while IFS= read -r FILE
do
    rm -f "$FILE"
    echo "Deleted: $FILE"
done <<< "$FILES"

echo "Cleanup completed."