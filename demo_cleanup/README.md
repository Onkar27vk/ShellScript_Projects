# Log Cleanup Automation - Complete Guide

## Overview
Automated shell script to clean up log files older than **6 days (T-6)** from your system. Perfect for DevOps automation and production environments.

## Files Included

1. **log_cleanup.sh** - Main cleanup script
2. **setup_cron.sh** - Automated cron installation
3. **test_cleanup.sh** - Test script with sample data

## Quick Start

### Method 1: Manual Cleanup (One-time)
```bash
# Clean logs in current directory, retention 6 days
./log_cleanup.sh

# Clean specific directory
./log_cleanup.sh /var/log/myapp

# Clean with custom retention (7 days)
./log_cleanup.sh /var/log/myapp 7

# Clean specific log pattern
./log_cleanup.sh /var/log/myapp 6 "app-*.log"

# DRY RUN - see what will be deleted without deleting
./log_cleanup.sh /var/log/myapp 6 "*.log" true
```

### Method 2: Schedule with Cron (Automated Daily)
```bash
# Setup automated cron job (requires sudo)
sudo bash setup_cron.sh /var/log/myapp 6 "*.log"

# Verify cron job installed
crontab -l | grep log_cleanup

# View scheduled cleanup logs
tail -f /var/log/log_cleanup_cron.log
```

### Method 3: Test First (Recommended)
```bash
# Test with sample log files
bash test_cleanup.sh
```

## Script Features

✓ **T-6 Day Retention** - Auto-delete logs older than 6 days  
✓ **Dry-Run Mode** - Preview what will be deleted  
✓ **Colored Output** - Easy-to-read console feedback  
✓ **Detailed Logging** - All actions logged to /var/log/log_cleanup_*.log  
✓ **Pattern Matching** - Filter logs by name pattern (*.log, app-*.log, etc.)  
✓ **Archive Support** - Option to archive before deletion  
✓ **Error Handling** - Comprehensive validation and error messages  
✓ **Cron Ready** - Easy scheduling for automation  

## Usage Examples

### Example 1: Daily Cleanup at 2 AM
```bash
sudo bash setup_cron.sh /var/log/myapp 6

# This creates cron job: 0 2 * * * /path/to/log_cleanup.sh /var/log/myapp 6 "*.log" false
```

### Example 2: Keep Logs for 14 Days
```bash
./log_cleanup.sh /var/log/myapp 14 "*.log"
```

### Example 3: Clean Only Application Logs
```bash
./log_cleanup.sh /var/log/myapp 6 "app-*.log"
```

### Example 4: Dry Run Before Cleanup
```bash
# See what will be deleted
./log_cleanup.sh /var/log/myapp 6 "*.log" true

# If satisfied, run actual cleanup
./log_cleanup.sh /var/log/myapp 6 "*.log" false
```

## Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| LOG_DIR | . (current) | Directory containing logs |
| RETENTION_DAYS | 6 | Days to keep logs |
| LOG_PATTERN | *.log | File pattern to match |
| DRY_RUN | false | Test run without deletion |

## Cron Scheduling Examples

Add to crontab with: `crontab -e`

```bash
# Daily cleanup at 2 AM
0 2 * * * /path/to/log_cleanup.sh /var/log/myapp 6 "*.log" false >> /var/log/log_cleanup_cron.log 2>&1

# Twice daily (2 AM & 2 PM)
0 2,14 * * * /path/to/log_cleanup.sh /var/log/myapp 6 "*.log" false >> /var/log/log_cleanup_cron.log 2>&1

# Weekly on Sunday at 3 AM
0 3 * * 0 /path/to/log_cleanup.sh /var/log/myapp 14 "*.log" false >> /var/log/log_cleanup_cron.log 2>&1

# Every 6 hours
0 */6 * * * /path/to/log_cleanup.sh /var/log/myapp 6 "*.log" false >> /var/log/log_cleanup_cron.log 2>&1
```

## Production Setup

### Step 1: Copy scripts to system
```bash
sudo cp log_cleanup.sh /usr/local/bin/log-cleanup
sudo cp setup_cron.sh /usr/local/bin/log-cleanup-setup
sudo chmod +x /usr/local/bin/log-cleanup*
```

### Step 2: Create log cleanup user (optional but recommended)
```bash
sudo useradd -r -s /bin/false logcleanup
sudo chown logcleanup:logcleanup /var/log/log_cleanup*.log
```

### Step 3: Schedule with cron
```bash
sudo bash setup_cron.sh /var/log/myapp 6 "app-*.log"
```

### Step 4: Verify setup
```bash
crontab -l
tail -f /var/log/log_cleanup_cron.log
```

## Log Files

- **Cleanup Log**: `/var/log/log_cleanup_YYYYMMDD.log` - Detailed cleanup info
- **Cron Log**: `/var/log/log_cleanup_cron.log` - Scheduled job output

View logs:
```bash
# Real-time monitoring
tail -f /var/log/log_cleanup_*.log

# See today's activity
grep "$(date +%Y-%m-%d)" /var/log/log_cleanup_*.log
```

## Troubleshooting

### Permission Denied
```bash
chmod +x log_cleanup.sh
```

### Cron not running
```bash
# Check if crond service is running
sudo systemctl status cron
sudo systemctl restart cron

# Check for errors in syslog
grep CRON /var/log/syslog | tail -20
```

### No files being deleted
```bash
# Run in dry-run mode to debug
./log_cleanup.sh /var/log/myapp 6 "*.log" true

# Check file ages manually
find /var/log/myapp -name "*.log" -mtime +6 -ls
```

### Permission issues with /var/log
```bash
# Check directory permissions
ls -ld /var/log/myapp

# Make script executable by others
sudo chmod +x log_cleanup.sh

# Run as root with sudo
sudo ./log_cleanup.sh /var/log/myapp 6
```

## Advanced Features

### Archive Instead of Delete
Edit `log_cleanup.sh` and set:
```bash
ARCHIVE_DIR="/var/log/archive"
```

Then logs will be compressed and archived instead of deleted.

### Custom Log Retention Policy
```bash
# Create different retention for different log types
./log_cleanup.sh /var/log/myapp 3 "error-*.log"    # Keep errors 3 days
./log_cleanup.sh /var/log/myapp 14 "access-*.log"  # Keep access logs 14 days
```

### Monitor Disk Space Freed
```bash
# See how much space will be freed
./log_cleanup.sh /var/log/myapp 6 "*.log" true | grep "Disk space"

# Clean and report
./log_cleanup.sh /var/log/myapp 6 "*.log" false
```

## Security Notes

1. **Run with sudo** if cleaning system directories
2. **Test first** with dry-run mode before production
3. **Monitor logs** for any errors or unexpected deletions
4. **Backup important logs** before automation
5. **Restrict script access** to authorized users

## Support

For issues or improvements, check:
- Script logs in `/var/log/log_cleanup_*.log`
- Cron execution logs in syslog: `grep CRON /var/log/syslog`
- Run in dry-run mode to debug issues

---

**Last Updated**: 2026-09-20  
**Version**: 1.0  
**License**: Open Source
