#!/bin/bash

################################################################################
# Log Cleanup Assistant - Quick Test Script
# Tests the log cleanup script with sample data
################################################################################

echo "═══════════════════════════════════════════════════════════════"
echo "  Log Cleanup - Quick Test"
echo "═══════════════════════════════════════════════════════════════"
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_DIR="$SCRIPT_DIR/test_logs"

# Create test directory
echo "1. Creating test log directory..."
mkdir -p "$TEST_DIR"

# Create sample logs of different ages
echo "2. Creating sample log files..."

# Current day logs
touch -d "1 day ago" "$TEST_DIR/app-2026-09-19.log"
echo "Creating log from 1 day ago"

# 6 day old logs
touch -d "6 days ago" "$TEST_DIR/app-2026-09-14.log"
echo "Creating log from 6 days ago"

# 7 day old logs (should be deleted with T-6 retention)
touch -d "7 days ago" "$TEST_DIR/app-2026-09-13.log"
echo "Creating log from 7 days ago"

# Add some content
echo "[INFO] Sample log content" >> "$TEST_DIR/app-2026-09-19.log"
echo "[INFO] Sample log content" >> "$TEST_DIR/app-2026-09-14.log"
echo "[INFO] Sample log content" >> "$TEST_DIR/app-2026-09-13.log"

echo ""
echo "3. Files created:"
ls -lh "$TEST_DIR/"
echo ""

# Run dry-run first
echo "4. Running DRY RUN (cleanup with -T-6 days, no actual deletion)..."
echo "────────────────────────────────────────────────────────────────"
bash "$SCRIPT_DIR/log_cleanup.sh" "$TEST_DIR" 6 "*.log" true
echo ""

# Ask user to proceed
read -p "5. Ready to actually delete old files? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Running actual cleanup..."
    bash "$SCRIPT_DIR/log_cleanup.sh" "$TEST_DIR" 6 "*.log" false
    echo ""
    echo "Files remaining after cleanup:"
    ls -lh "$TEST_DIR/"
else
    echo "Cleanup cancelled."
fi

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  Test completed! Check $TEST_DIR/"
echo "═══════════════════════════════════════════════════════════════"

