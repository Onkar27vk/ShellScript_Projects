# Log Cleanup - Systemd Service & Timer
# Alternative to Cron for modern Linux systems

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# File 1: /etc/systemd/system/log-cleanup.service
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[Unit]
Description=Automated Log Cleanup Service (T-6 days)
After=syslog.target network.target

[Service]
Type=oneshot
User=root
ExecStart=/usr/local/bin/log-cleanup /var/log/myapp 6 "*.log" false
StandardOutput=journal
StandardError=journal

# Uncomment to run as specific user
# User=logcleanup
# Group=logcleanup

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# File 2: /etc/systemd/system/log-cleanup.timer
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[Unit]
Description=Daily Log Cleanup Timer (2 AM)
Requires=log-cleanup.service

[Timer]
# Run daily at 2 AM
OnCalendar=*-*-* 02:00:00

# Run 5 minutes after boot if missed
Persistent=true
AccuracySec=1min

# Alternative schedules:
# OnCalendar=*-*-* 02:00:00         # Daily at 2 AM
# OnCalendar=*-*-* 02,14:00:00      # Twice daily (2 AM & 2 PM)
# OnCalendar=Sun *-*-* 03:00:00     # Weekly Sunday 3 AM
# OnBootSec=5min                     # 5 minutes after boot
# OnUnitActiveSec=6h                 # Every 6 hours after last run

[Install]
WantedBy=timers.target

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# INSTALLATION INSTRUCTIONS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# 1. Copy files to systemd directory
# sudo cp /etc/systemd/system/log-cleanup.service /etc/systemd/system/
# sudo cp /etc/systemd/system/log-cleanup.timer /etc/systemd/system/

# 2. Reload systemd daemon
# sudo systemctl daemon-reload

# 3. Enable and start the timer
# sudo systemctl enable log-cleanup.timer
# sudo systemctl start log-cleanup.timer

# 4. Verify timer is active
# sudo systemctl status log-cleanup.timer

# 5. Check when it will run next
# sudo systemctl list-timers log-cleanup.timer

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USEFUL SYSTEMD COMMANDS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# View service status
# sudo systemctl status log-cleanup.service

# View timer status
# sudo systemctl status log-cleanup.timer

# Check next run time
# sudo systemctl list-timers log-cleanup.timer

# View service logs
# sudo journalctl -u log-cleanup.service -n 50

# Real-time service logs
# sudo journalctl -f -u log-cleanup.service

# Last 5 executions
# sudo journalctl -u log-cleanup.service | tail -20

# Manually trigger service (for testing)
# sudo systemctl start log-cleanup.service

# Stop timer (no more scheduled runs)
# sudo systemctl stop log-cleanup.timer
# sudo systemctl disable log-cleanup.timer

# View all timers
# sudo systemctl list-timers

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SCHEDULE EXAMPLES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# DAILY SCHEDULES:
# OnCalendar=*-*-* 02:00:00         # Every day at 2:00 AM
# OnCalendar=*-*-* 14:00:00         # Every day at 2:00 PM
# OnCalendar=*-*-* 02,14:00:00      # Twice daily (2 AM & 2 PM)

# WEEKLY SCHEDULES:
# OnCalendar=Sun *-*-* 03:00:00     # Sunday at 3 AM
# OnCalendar=Mon-Fri *-*-* 02:00:00 # Weekdays at 2 AM
# OnCalendar=Sat *-*-* 03:00:00     # Saturday at 3 AM

# HOURLY SCHEDULES:
# OnCalendar=*-*-* *:00:00          # Every hour
# OnCalendar=*-*-* 00/6:00:00       # Every 6 hours

# BOOT-BASED SCHEDULES:
# OnBootSec=5min                     # 5 minutes after boot
# OnBootSec=1h                       # 1 hour after boot
# OnUnitActiveSec=24h                # 24 hours after last run

# COMBINED:
# OnBootSec=1h
# OnCalendar=*-*-* 02:00:00          # Run at boot + daily at 2 AM

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# QUICK SETUP SCRIPT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

#!/bin/bash
# save as setup_systemd.sh and run with sudo

LOG_DIR="${1:-/var/log/myapp}"
RETENTION_DAYS="${2:-6}"
LOG_PATTERN="${3:-*.log}"
CLEANUP_SCRIPT="${4:-/usr/local/bin/log-cleanup}"

echo "Creating systemd service..."
sudo tee /etc/systemd/system/log-cleanup.service > /dev/null <<EOF
[Unit]
Description=Automated Log Cleanup Service (T-$RETENTION_DAYS days)
After=syslog.target network.target

[Service]
Type=oneshot
User=root
ExecStart=$CLEANUP_SCRIPT $LOG_DIR $RETENTION_DAYS "$LOG_PATTERN" false
StandardOutput=journal
StandardError=journal
EOF

echo "Creating systemd timer..."
sudo tee /etc/systemd/system/log-cleanup.timer > /dev/null <<EOF
[Unit]
Description=Daily Log Cleanup Timer
Requires=log-cleanup.service

[Timer]
OnCalendar=*-*-* 02:00:00
Persistent=true
AccuracySec=1min

[Install]
WantedBy=timers.target
EOF

echo "Reloading systemd daemon..."
sudo systemctl daemon-reload

echo "Enabling and starting timer..."
sudo systemctl enable log-cleanup.timer
sudo systemctl start log-cleanup.timer

echo "Verification:"
sudo systemctl status log-cleanup.timer
sudo systemctl list-timers log-cleanup.timer

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ADVANTAGES OVER CRON
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# ✓ Better logging integration (journalctl)
# ✓ More flexible scheduling syntax
# ✓ Persistent - runs missed jobs if system reboots
# ✓ Better error handling and notifications
# ✓ Can be triggered manually easily
# ✓ Better resource management
# ✓ Integrates with systemd ecosystem
# ✓ Runs with proper service dependencies

