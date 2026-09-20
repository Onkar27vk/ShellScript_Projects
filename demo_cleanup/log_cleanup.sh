#!/bin/bash

################################################################################
# Log Cleanup Automation Script
# Purpose: Remove log files older than 6 days (T-6)
# Author: DevOps Team
# Date: 2026-09-20
################################################################################

# Configuration
LOG_DIR="${1:-.}"                          # Default to current directory
RETENTION_DAYS="${2:-6}"                   # Default to 6 days
LOG_PATTERN="${3:-*.log}"                  # Default log file pattern
DRY_RUN="${4:-false}"                      # Default to actual deletion
CLEANUP_LOG="/var/log/log_cleanup_$(date +%Y%m%d).log"
ARCHIVE_DIR=""                             # Set if you want to archive instead of delete

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

################################################################################
# Functions
################################################################################

# Logging function
log_message() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" | tee -a "$CLEANUP_LOG"
}

# Print colored output
print_status() {
    local status=$1
    local message=$2
    case $status in
        "SUCCESS") echo -e "${GREEN}✓ $message${NC}" ;;
        "ERROR")   echo -e "${RED}✗ $message${NC}" ;;
        "WARNING") echo -e "${YELLOW}⚠ $message${NC}" ;;
        "INFO")    echo -e "${BLUE}ℹ $message${NC}" ;;
    esac
}

# Validate directory exists
validate_directory() {
    if [ ! -d "$LOG_DIR" ]; then
        print_status "ERROR" "Directory does not exist: $LOG_DIR"
        log_message "ERROR" "Directory does not exist: $LOG_DIR"
        exit 1
    fi
}

# Count files before cleanup
count_files_before() {
    find "$LOG_DIR" -maxdepth 1 -name "$LOG_PATTERN" -type f | wc -l
}

# Calculate disk space
calculate_disk_space() {
    find "$LOG_DIR" -maxdepth 1 -name "$LOG_PATTERN" -type f -mtime +$RETENTION_DAYS -exec du -sh {} + | awk '{sum+=$1} END {print sum}'
}

# Archive logs instead of deleting
archive_logs() {
    local archive_path="${ARCHIVE_DIR}/archived_logs_$(date +%Y%m%d_%H%M%S).tar.gz"
    
    print_status "INFO" "Archiving logs older than $RETENTION_DAYS days..."
    
    if find "$LOG_DIR" -maxdepth 1 -name "$LOG_PATTERN" -type f -mtime +$RETENTION_DAYS | \
       tar -czf "$archive_path" -T - 2>/dev/null; then
        print_status "SUCCESS" "Logs archived to: $archive_path"
        log_message "INFO" "Logs archived to: $archive_path"
        
        # Delete after successful archive
        find "$LOG_DIR" -maxdepth 1 -name "$LOG_PATTERN" -type f -mtime +$RETENTION_DAYS -delete
    else
        print_status "ERROR" "Failed to archive logs"
        log_message "ERROR" "Failed to archive logs"
        return 1
    fi
}

# Delete logs older than retention days
cleanup_logs() {
    local files_count=$(count_files_before)
    local disk_space=$(calculate_disk_space)
    
    print_status "INFO" "Starting log cleanup process..."
    echo ""
    print_status "INFO" "Log Directory: $LOG_DIR"
    print_status "INFO" "Log Pattern: $LOG_PATTERN"
    print_status "INFO" "Retention Days: $RETENTION_DAYS"
    print_status "INFO" "Files to be cleaned: $files_count"
    print_status "INFO" "Disk space to free: $disk_space"
    echo ""
    
    if [ "$DRY_RUN" = "true" ]; then
        print_status "WARNING" "DRY RUN MODE - No files will be deleted"
        log_message "INFO" "DRY RUN: Files that would be deleted:"
        find "$LOG_DIR" -maxdepth 1 -name "$LOG_PATTERN" -type f -mtime +$RETENTION_DAYS | while read -r file; do
            local file_age=$(echo "$(date +%s) - $(stat -c %Y "$file" 2>/dev/null || stat -f %m "$file")" | bc)
            local file_age_days=$((file_age / 86400))
            echo "  - $(basename "$file") (Age: $file_age_days days)"
            log_message "INFO" "DRY RUN: Would delete - $(basename "$file") (Age: $file_age_days days)"
        done
        echo ""
        return 0
    fi
    
    # Archive if configured, otherwise delete
    if [ -n "$ARCHIVE_DIR" ] && [ -d "$ARCHIVE_DIR" ]; then
        archive_logs
    else
        # Delete old logs
        local deleted_count=0
        find "$LOG_DIR" -maxdepth 1 -name "$LOG_PATTERN" -type f -mtime +$RETENTION_DAYS | while read -r file; do
            if rm -f "$file"; then
                ((deleted_count++))
                print_status "SUCCESS" "Deleted: $(basename "$file")"
                log_message "INFO" "Deleted: $(basename "$file")"
            else
                print_status "ERROR" "Failed to delete: $(basename "$file")"
                log_message "ERROR" "Failed to delete: $(basename "$file")"
            fi
        done
    fi
}

# Generate cleanup report
generate_report() {
    local files_remaining=$(count_files_before)
    
    echo ""
    echo "════════════════════════════════════════════════════════════"
    print_status "SUCCESS" "Log Cleanup Completed Successfully"
    echo "════════════════════════════════════════════════════════════"
    print_status "INFO" "Cleanup Log: $CLEANUP_LOG"
    print_status "INFO" "Remaining log files: $files_remaining"
    echo ""
    log_message "INFO" "Cleanup process completed"
}

# Show usage
show_usage() {
    cat << EOF
Usage: $0 [LOG_DIR] [RETENTION_DAYS] [LOG_PATTERN] [DRY_RUN]

Options:
    LOG_DIR         - Directory containing log files (default: current directory)
    RETENTION_DAYS  - Number of days to retain logs (default: 6)
    LOG_PATTERN     - File pattern to match (default: *.log)
    DRY_RUN         - Test run without deleting (true/false, default: false)

Examples:
    # Clean logs older than 6 days in current directory
    $0

    # Clean logs older than 7 days in /var/log
    $0 /var/log 7

    # Dry run to see what would be deleted
    $0 /var/log 6 "*.log" true

    # Clean specific log files
    $0 /var/log 6 "app-*.log"

Using with Cron (Add to crontab):
    # Run daily cleanup at 2 AM
    0 2 * * * /path/to/log_cleanup.sh /var/log/myapp 6 "app-*.log" false >> /var/log/cleanup.log 2>&1

    # Run weekly cleanup at Sunday 3 AM
    0 3 * * 0 /path/to/log_cleanup.sh /var/log/myapp 14 "*.log" false

EOF
}

################################################################################
# Main Script
################################################################################

# Check for help flag
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_usage
    exit 0
fi

# Validate inputs
if [ ! -d "$LOG_DIR" ]; then
    print_status "ERROR" "Log directory does not exist: $LOG_DIR"
    exit 1
fi

if ! [[ "$RETENTION_DAYS" =~ ^[0-9]+$ ]]; then
    print_status "ERROR" "Retention days must be a number"
    exit 1
fi

# Create log directory if cleanup log will be stored elsewhere
mkdir -p "$(dirname "$CLEANUP_LOG")" 2>/dev/null

# Start cleanup
log_message "INFO" "Starting log cleanup - LOG_DIR=$LOG_DIR, RETENTION_DAYS=$RETENTION_DAYS, PATTERN=$LOG_PATTERN"
cleanup_logs
generate_report

exit 0
