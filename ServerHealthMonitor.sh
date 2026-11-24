#!/usr/bin/env bash
set -eu

# Configuration Variables
LOG_FILE="$HOME/server_health.log"
DISK_THRESHOLD=80

# Module 1: System Identity & Uptime
check_system_info() {
    echo "========================================"
    echo "SERVER HEALTH REPORT"
    echo "Host:   $(hostname)"
    echo "Date:   $(date '+%Y-%m-%d %H:%M:%S')"
    echo "Uptime: $(uptime -p)"
    echo "========================================"
}

# Module 2: Memory (RAM) Telemetry
check_memory() {
    echo -e "\n[1] MEMORY (RAM) USAGE:"
    free -h | awk 'NR==1 || NR==2 {print $0}'
}

# Module 3: Disk Capacity & Threshold Alerting
check_disk() {
    echo -e "\n[2] DISK USAGE (Root Partition /):"
    df -h / | awk 'NR==1 || NR==2 {print $0}'

    local usage
    usage=$(df / | awk 'NR==2 {print $5}' | tr -d '%')

    if [ "$usage" -ge "$DISK_THRESHOLD" ]; then
        echo "WARNING: Disk usage is at ${usage}% (Threshold: ${DISK_THRESHOLD}%)"
    else
        echo "STATUS: Disk space is healthy (${usage}% used)"
    fi
}

# Module 4: Top 10 CPU-Consuming Processes
check_top_processes() {
    echo -e "\n[3] TOP 10 CPU-CONSUMING PROCESSES:"
    ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 11
}

# Master Orchestrator Function
main() {
    {
        check_system_info
        check_memory
        check_disk
        check_top_processes
        echo -e "\nReport logged to: $LOG_FILE\n"
    } | tee -a "$LOG_FILE"
}

# Execute the script
main