#!/bin/bash

# 🚀 LOG CLEANUP - QUICK REFERENCE CHEAT SHEET
# T-6 Day Retention Automation

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BASIC COMMANDS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Quick cleanup (current directory, 6 days retention)
./log_cleanup.sh

# Cleanup specific directory
./log_cleanup.sh /var/log/myapp

# Cleanup with custom retention (7 days)
./log_cleanup.sh /var/log/myapp 7

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ADVANCED USAGE
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Cleanup specific pattern (app logs only)
./log_cleanup.sh /var/log/myapp 6 "app-*.log"

# DRY RUN - Preview deletion without deleting
./log_cleanup.sh /var/log/myapp 6 "*.log" true

# Multiple patterns cleanup
./log_cleanup.sh /var/log/myapp 6 "error-*.log" false

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CROND/SCHEDULING
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Auto-setup cron job
sudo bash setup_cron.sh /var/log/myapp 6

# View cron jobs
crontab -l

# Edit cron jobs
crontab -e

# Remove cron job
crontab -r

# Check cron service
sudo systemctl status cron

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# COMMON CRON SCHEDULES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Daily at 2 AM (most common)
0 2 * * * /path/to/log_cleanup.sh /var/log/myapp 6 "*.log" false >> /var/log/log_cleanup_cron.log 2>&1

# Twice daily (2 AM & 2 PM)
0 2,14 * * * /path/to/log_cleanup.sh /var/log/myapp 6 "*.log" false >> /var/log/log_cleanup_cron.log 2>&1

# Weekly Sunday 3 AM
0 3 * * 0 /path/to/log_cleanup.sh /var/log/myapp 14 "*.log" false >> /var/log/log_cleanup_cron.log 2>&1

# Every 6 hours
0 */6 * * * /path/to/log_cleanup.sh /var/log/myapp 6 "*.log" false >> /var/log/log_cleanup_cron.log 2>&1

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MONITORING & VERIFICATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# View cleanup logs
tail -f /var/log/log_cleanup*.log

# Today's cleanup activity
grep "$(date +%Y-%m-%d)" /var/log/log_cleanup*.log

# Check cron execution logs
grep CRON /var/log/syslog | tail -20

# List files older than 6 days (what would be deleted)
find /var/log/myapp -name "*.log" -mtime +6 -ls

# Check disk space freed
du -sh /var/log/myapp

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# INSTALLATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Make scripts executable
chmod +x log_cleanup.sh setup_cron.sh test_cleanup.sh

# Copy to system path
sudo cp log_cleanup.sh /usr/local/bin/log-cleanup
sudo chmod +x /usr/local/bin/log-cleanup

# Test with sample data
bash test_cleanup.sh

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TROUBLESHOOTING
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Test without deleting (DRY RUN)
./log_cleanup.sh /var/log/myapp 6 "*.log" true

# Test script execution
bash -x log_cleanup.sh /var/log/myapp 6 "*.log" false

# Check file permissions
ls -l log_cleanup.sh

# Restart cron service
sudo systemctl restart cron

# Test manual cron execution
/path/to/log_cleanup.sh /var/log/myapp 6

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# RETENTION PERIODS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# T-3 days (very short, high-volume apps)
./log_cleanup.sh /var/log/myapp 3

# T-6 days (default, weekly cleanup)
./log_cleanup.sh /var/log/myapp 6

# T-14 days (bi-weekly cleanup)
./log_cleanup.sh /var/log/myapp 14

# T-30 days (monthly cleanup)
./log_cleanup.sh /var/log/myapp 30

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# COMMON LOG PATTERNS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# All log files
./log_cleanup.sh /var/log/myapp 6 "*.log"

# Application logs
./log_cleanup.sh /var/log/myapp 6 "app-*.log"

# Error logs only
./log_cleanup.sh /var/log/myapp 6 "error-*.log"

# Access logs
./log_cleanup.sh /var/log/myapp 6 "access-*.log"

# Dated logs
./log_cleanup.sh /var/log/myapp 6 "*.log.*"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PRODUCTION CHECKLIST
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# ☐ Test with dry-run first
# ☐ Verify retention period (6, 14, 30 days)
# ☐ Confirm log pattern matches correct files
# ☐ Set up cron schedule
# ☐ Monitor first cleanup run
# ☐ Watch cleanup logs for errors
# ☐ Verify disk space is freed
# ☐ Document custom retention if used

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USEFUL COMMANDS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Find largest log files
find /var/log/myapp -name "*.log" -type f -exec ls -lh {} \; | sort -k5 -hr | head -10

# Count log files
find /var/log/myapp -name "*.log" -type f | wc -l

# Total log size
du -sh /var/log/myapp

# File modified dates
ls -lh /var/log/myapp/*.log | awk '{print $6, $7, $8, $9}'

# Manual removal of old logs
find /var/log/myapp -name "*.log" -mtime +6 -delete

# Archive old logs instead
find /var/log/myapp -name "*.log" -mtime +6 | tar -czf /backup/logs_$(date +%Y%m%d).tar.gz -T -

