#!/bin/bash

################################################################################
# Log Cleanup - Cron Setup Script
# Purpose: Automate installation of log cleanup job
# Usage: sudo bash setup_cron.sh
################################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLEANUP_SCRIPT="$SCRIPT_DIR/log_cleanup.sh"
LOG_DIR="${1:-/var/log/myapp}"
RETENTION_DAYS="${2:-6}"
LOG_PATTERN="${3:-*.log}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Log Cleanup - Cron Setup${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
   echo -e "${RED}✗ This script must be run with sudo${NC}"
   exit 1
fi

# Make cleanup script executable
if [ ! -f "$CLEANUP_SCRIPT" ]; then
    echo -e "${RED}✗ Error: log_cleanup.sh not found at $CLEANUP_SCRIPT${NC}"
    exit 1
fi

chmod +x "$CLEANUP_SCRIPT"
echo -e "${GREEN}✓ Made script executable${NC}"

# Create cron job
CRON_CMD="0 2 * * * $CLEANUP_SCRIPT $LOG_DIR $RETENTION_DAYS \"$LOG_PATTERN\" false >> /var/log/log_cleanup_cron.log 2>&1"

# Check if cron job already exists
if crontab -l 2>/dev/null | grep -q "$CLEANUP_SCRIPT"; then
    echo -e "${YELLOW}⚠ Cron job already exists${NC}"
    echo "Current cron jobs:"
    crontab -l | grep "$CLEANUP_SCRIPT"
else
    # Add new cron job
    (crontab -l 2>/dev/null; echo "$CRON_CMD") | crontab -
    echo -e "${GREEN}✓ Cron job installed successfully${NC}"
fi

echo ""
echo -e "${BLUE}Configuration:${NC}"
echo "  Log Directory: $LOG_DIR"
echo "  Retention Days: $RETENTION_DAYS"
echo "  Log Pattern: $LOG_PATTERN"
echo "  Schedule: 2:00 AM daily"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "  1. Verify cron job: crontab -l | grep log_cleanup"
echo "  2. Test manually: $CLEANUP_SCRIPT $LOG_DIR $RETENTION_DAYS \"$LOG_PATTERN\" true"
echo "  3. View logs: tail -f /var/log/log_cleanup_cron.log"
echo ""

