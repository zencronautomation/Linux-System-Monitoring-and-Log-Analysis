#!/bin/bash
# ==============================================================================
# Linux System Monitor & Auto-Installer
# Target: Debian 13 (Trixie) | 2 CPU, 3GB RAM, 30GB Disk
# ==============================================================================

set -u # Exit on undefined variables

BASE_DIR="$HOME/linux-system-monitor"
LOG_DIR="$BASE_DIR/logs"
LOG_FILE="$LOG_DIR/system_monitor.log"
CONFIG_FILE="$BASE_DIR/config.env"
INSTALL_MARKER="$BASE_DIR/.installed"

# ------------------------------------------------------------------------------
# PHASE 1: AUTOMATED SETUP & INSTALLATION (Runs only on first execution)
# ------------------------------------------------------------------------------
if [ ! -f "$INSTALL_MARKER" ]; then
    echo "[*] First run detected. Bootstrapping Linux System Monitor..."
    
    # 1. Install required dependencies
    echo "[*] Installing dependencies (cron, logrotate, procps, sysstat)..."
    apt-get update -qq
    apt-get install -y -qq cron logrotate procps sysstat > /dev/null 2>&1
    
    # 2. Create directory structure
    mkdir -p "$LOG_DIR"
    
    # 3. Generate Configuration File
    cat <<EOF > "$CONFIG_FILE"
# System Monitor Thresholds
CPU_THRESHOLD=85
MEMORY_THRESHOLD=80
DISK_THRESHOLD=80
INODE_THRESHOLD=80
EOF
    echo "[*] Configuration file created at $CONFIG_FILE"

    # 4. Setup Logrotate to protect the 30GB disk
    LOGROTATE_CONF="/etc/logrotate.d/linux-system-monitor"
    cat <<EOF | sudo tee "$LOGROTATE_CONF" > /dev/null
$LOG_DIR/*.log {
    daily
    rotate 14
    compress
    delaycompress
    missingok
    notifempty
    size 5M
    create 0644 $USER $USER
}
EOF
    echo "[*] Logrotate configured to prevent disk exhaustion."

    # 5. Setup Cron Job (Every 5 minutes)
    # We filter out any existing entries for this script to prevent duplicates
    (crontab -l 2>/dev/null | grep -v "system_monitor.sh"; echo "*/5 * * * * $BASE_DIR/system_monitor.sh") | crontab -
    echo "[*] Cron job scheduled to run every 5 minutes."

    # 6. Ensure cron service is running
    systemctl enable --now cron > /dev/null 2>&1

    # 7. Mark installation as complete
    touch "$INSTALL_MARKER"
    echo "[✓] Setup complete! The monitor will now run automatically every 5 minutes."
    echo "[✓] You can view logs at: $LOG_FILE"
    exit 0
fi

# ------------------------------------------------------------------------------
# PHASE 2: SYSTEM MONITORING (Runs every 5 minutes via Cron)
# ------------------------------------------------------------------------------

# Source configuration
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo "Error: Config file not found at $CONFIG_FILE" >&2
    exit 1
fi

# Ensure log directory exists (safety check)
mkdir -p "$LOG_DIR"

# Get current timestamp
NOW=$(date "+%Y-%m-%d %H:%M:%S")

# --- Gather System Metrics ---
HOSTNAME=$(hostname)
UPTIME=$(uptime -p 2>/dev/null || uptime)
LOAD=$(cat /proc/loadavg | awk '{print $1, $2, $3}')

# Memory Usage (Percentage)
MEM_TOTAL=$(free | awk '/Mem:/ {print $2}')
MEM_USED=$(free | awk '/Mem:/ {print $3}')
MEM_PCT=$(awk "BEGIN {printf \"%.0f\", ($MEM_USED/$MEM_TOTAL)*100}")

# Disk Usage (Percentage & Inodes)
DISK_PCT=$(df / | awk 'NR==2 {gsub(/%/,"",$5); print $5}')
INODE_PCT=$(df -i / | awk 'NR==2 {gsub(/%/,"",$5); print $5}')

# CPU Usage (Using vmstat for reliable parsing across Debian versions)
# vmstat 1 2 takes two samples 1 second apart, we take the last line.
CPU_IDLE=$(vmstat 1 2 | tail -1 | awk '{print $15}')
CPU_PCT=$(awk "BEGIN {print 100 - $CPU_IDLE}")

# Top 5 CPU Processes
TOP_PROCS=$(ps aux --sort=-%cpu | head -n 6)

# --- Real-World Checks ---
# 1. Failed Systemd Services
FAILED_SERVICES=$(systemctl --failed --no-legend 2>/dev/null | awk '{print $2}' | tr '\n' ', ' | sed 's/,$//')
if [ -z "$FAILED_SERVICES" ]; then FAILED_SERVICES="None"; fi

# 2. Recent OOM (Out of Memory) Kills
OOM_KILLS=$(dmesg -T 2>/dev/null | grep -i "out of memory" | tail -n 3 | awk -F'] ' '{print $2}')
if [ -z "$OOM_KILLS" ]; then OOM_KILLS="None detected"; fi

# --- Write to Log File ---
{
    echo "======================================================================"
    echo " SYSTEM CHECK: $NOW "
    echo "======================================================================"
    echo "Hostname : $HOSTNAME"
    echo "Uptime   : $UPTIME"
    echo "Load Avg : $LOAD"
    echo ""
    echo "--- Resource Utilization ---"
    echo "CPU Used    : ${CPU_PCT}%"
    echo "Memory Used : ${MEM_PCT}% ($((MEM_USED/1024))MB / $((MEM_TOTAL/1024))MB)"
    echo "Disk Used   : ${DISK_PCT}% (Root Partition)"
    echo "Inodes Used : ${INODE_PCT}% (Root Partition)"
    echo ""
    echo "--- Real-World Health Checks ---"
    echo "Failed Services: $FAILED_SERVICES"
    echo "Recent OOM Kills:"
    echo "$OOM_KILLS" | sed 's/^/    /'
    echo ""
    echo "--- Top 5 CPU Processes ---"
    echo "$TOP_PROCS"
    echo ""
    echo "--- Threshold Warnings ---"
    
    # Check Thresholds
    WARNINGS_TRIGGERED=0
    if [ "$CPU_PCT" -ge "$CPU_THRESHOLD" ]; then
        echo "[WARNING] CPU usage (${CPU_PCT}%) exceeded threshold (${CPU_THRESHOLD}%)"
        WARNINGS_TRIGGERED=1
    fi
    if [ "$MEM_PCT" -ge "$MEMORY_THRESHOLD" ]; then
        echo "[WARNING] Memory usage (${MEM_PCT}%) exceeded threshold (${MEMORY_THRESHOLD}%)"
        WARNINGS_TRIGGERED=1
    fi
    if [ "$DISK_PCT" -ge "$DISK_THRESHOLD" ]; then
        echo "[WARNING] Disk usage (${DISK_PCT}%) exceeded threshold (${DISK_THRESHOLD}%)"
        WARNINGS_TRIGGERED=1
    fi
    if [ "$INODE_PCT" -ge "$INODE_THRESHOLD" ]; then
        echo "[WARNING] Inode usage (${INODE_PCT}%) exceeded threshold (${INODE_THRESHOLD}%)"
        WARNINGS_TRIGGERED=1
    fi
    
    if [ "$WARNINGS_TRIGGERED" -eq 0 ]; then
        echo "All systems operating within normal thresholds."
    fi

    echo "======================================================================"
    echo ""
} >> "$LOG_FILE" 2>/dev/null

# --- Fallback Alerting (Crucial for 30GB Disks) ---
# If the disk is critically full (>95%), the log write above might fail.
# We use the native 'logger' command to send an alert to /var/log/syslog.
if [ "$DISK_PCT" -ge 95 ]; then
    logger -p crit -t SystemMonitor "CRITICAL: Root disk usage is at ${DISK_PCT}%. Immediate action required."
fi
if [ "$INODE_PCT" -ge 95 ]; then
    logger -p crit -t SystemMonitor "CRITICAL: Root inode usage is at ${INODE_PCT}%. System may fail to create new files."
fi

exit 0
