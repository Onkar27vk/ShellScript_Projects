#!/bin/bash

THRESHOLD=80

USAGE=$(df / | awk 'NR==2 {print $5}' | tr -d '%')

echo "Current disk usage: $USAGE%"

if [[ "$USAGE" -gt "$THRESHOLD" ]]; then
    echo "WARNING: Disk usage is above $THRESHOLD%"
    exit 1
else
    echo "Disk usage is normal"
    exit 0
fi