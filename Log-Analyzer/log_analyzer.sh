#!/bin/bash

LOG_FILE="application.log"
REPORT="log_report_$(date +%F_%H%M%S).txt"

if [ ! -f "$LOG_FILE" ]
then
    echo "ERROR: Log file not found"
    exit 1
fi

echo "==================================" > "$REPORT"
echo "      APPLICATION LOG REPORT" >> "$REPORT"
echo "==================================" >> "$REPORT"

TOTAL_LINES=$(wc -l < "$LOG_FILE")
ERROR_COUNT=$(grep -ci "ERROR" "$LOG_FILE")
WARN_COUNT=$(grep -ci "WARN" "$LOG_FILE")
TIMEOUT_COUNT=$(grep -ci "timeout" "$LOG_FILE")
HTTP_500=$(grep -c " 500" "$LOG_FILE")
HTTP_404=$(grep -c " 404" "$LOG_FILE")

echo "Total Log Entries : $TOTAL_LINES" >> "$REPORT"
echo "ERROR Count       : $ERROR_COUNT" >> "$REPORT"
echo "WARN Count        : $WARN_COUNT" >> "$REPORT"
echo "Timeout Count     : $TIMEOUT_COUNT" >> "$REPORT"
echo "HTTP 500 Count    : $HTTP_500" >> "$REPORT"
echo "HTTP 404 Count    : $HTTP_404" >> "$REPORT"

echo "" >> "$REPORT"
echo "----- ERROR LOGS -----" >> "$REPORT"
grep -i "ERROR" "$LOG_FILE" >> "$REPORT"

echo "" >> "$REPORT"
echo "----- RECENT ERRORS -----" >> "$REPORT"
grep -i "ERROR" "$LOG_FILE" | tail -5 >> "$REPORT"

echo "" >> "$REPORT"
echo "----- TIMEOUT EVENTS -----" >> "$REPORT"
grep -i "timeout" "$LOG_FILE" >> "$REPORT"

echo "" >> "$REPORT"
echo "----- INCIDENT STATUS -----" >> "$REPORT"

if [ "$ERROR_COUNT" -ge 5 ]
then
    echo "CRITICAL: High number of application errors detected." >> "$REPORT"
elif [ "$ERROR_COUNT" -gt 0 ]
then
    echo "WARNING: Application errors detected." >> "$REPORT"
else
    echo "OK: No application errors detected." >> "$REPORT"
fi

echo "" >> "$REPORT"
echo "Report generated: $REPORT"

cat "$REPORT"
