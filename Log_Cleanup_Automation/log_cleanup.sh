#!/bin/bash

# ===================================================
# Log Cleanup Automation Script
# Removes log entries older than specified days
# ===================================================

LOG_FILE="log.txt"
DAYS=3
BACKUP_FILE="log_backup_$(date +%Y%m%d_%H%M%S).txt"
CUTOFF_DATE=$(date -d "$DAYS days ago" +%Y-%m-%d)

echo "=================================================="
echo "Log Cleanup Automation"
echo "=================================================="
echo "Log File: $LOG_FILE"
echo "Days to Keep: $DAYS"
echo "Cutoff Date: $CUTOFF_DATE"
echo ""

# Check if log file exists
if [[ ! -f "$LOG_FILE" ]]; then
    echo "ERROR: Log file '$LOG_FILE' not found!"
    exit 1
fi

# Create backup before deletion
echo "Creating backup: $BACKUP_FILE"
cp "$LOG_FILE" "$BACKUP_FILE"
echo "✓ Backup created"
echo ""

# Count total lines before cleanup
TOTAL_BEFORE=$(wc -l < "$LOG_FILE")
echo "Total log lines before cleanup: $TOTAL_BEFORE"

# Filter logs - keep only entries from last 3 days
echo "Processing... Removing entries older than $DAYS days"
grep "^$CUTOFF_DATE\|^$(date +%Y-%m-%d)\|^$(date -d '1 day ago' +%Y-%m-%d)\|^$(date -d '2 days ago' +%Y-%m-%d)" "$LOG_FILE" > "${LOG_FILE}.tmp"

# Count lines after cleanup
TOTAL_AFTER=$(wc -l < "${LOG_FILE}.tmp")
DELETED=$((TOTAL_BEFORE - TOTAL_AFTER))

echo ""
echo "Results:"
echo "--------"
echo "✓ Total lines before cleanup: $TOTAL_BEFORE"
echo "✓ Total lines after cleanup: $TOTAL_AFTER"
echo "✓ Lines deleted: $DELETED"

# Replace original with cleaned file
mv "${LOG_FILE}.tmp" "$LOG_FILE"

echo ""
echo "=================================================="
echo "✓ Cleanup completed successfully!"
echo "✓ Backup saved as: $BACKUP_FILE"
echo "=================================================="