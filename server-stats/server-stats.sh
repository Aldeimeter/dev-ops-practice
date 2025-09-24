#!/bin/bash

# Server Stats Analysis Script
# Analyzes basic server performance statistics

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print section headers
print_header() {
    echo -e "\n${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

# Function to print subsection headers
print_subheader() {
    echo -e "\n${CYAN}--- $1 ---${NC}"
}

# Function to get CPU usage
get_cpu_usage() {
    print_header "CPU USAGE"

    # Method 1: Using top command
    if command -v top >/dev/null 2>&1; then
        cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | sed 's/%us,//')
        if [[ -n "$cpu_usage" ]]; then
            echo -e "Current CPU Usage: ${YELLOW}${cpu_usage}%${NC}"
        fi
    fi

    # Method 2: Calculate from /proc/stat (more accurate)
    if [[ -r /proc/stat ]]; then
        # Read CPU stats twice with 1 second interval for accurate measurement
        read cpu_line_1 < <(head -n 1 /proc/stat)
        sleep 1
        read cpu_line_2 < <(head -n 1 /proc/stat)

        # Parse the values
        cpu_times_1=($cpu_line_1)
        cpu_times_2=($cpu_line_2)

        # Calculate the differences
        idle_1=${cpu_times_1[4]}
        idle_2=${cpu_times_2[4]}

        total_1=0
        total_2=0
        for value in "${cpu_times_1[@]:1}"; do
            total_1=$((total_1 + value))
        done
        for value in "${cpu_times_2[@]:1}"; do
            total_2=$((total_2 + value))
        done

        # Calculate CPU usage percentage
        idle_diff=$((idle_2 - idle_1))
        total_diff=$((total_2 - total_1))

        if [[ $total_diff -gt 0 ]]; then
            cpu_usage=$(( 100 * (total_diff - idle_diff) / total_diff ))
            echo -e "Calculated CPU Usage: ${YELLOW}${cpu_usage}%${NC}"
        fi
    fi

    # Load averages
    if [[ -r /proc/loadavg ]]; then
        load_avg=$(cat /proc/loadavg | awk '{print $1, $2, $3}')
        echo -e "Load Average (1m, 5m, 15m): ${GREEN}${load_avg}${NC}"
    fi
}

# Function to get memory usage
get_memory_usage() {
    print_header "MEMORY USAGE"

    if command -v free >/dev/null 2>&1; then
        # Get memory info using free command
        memory_info=$(free -h)
        echo -e "${memory_info}"

        # Calculate percentages
        memory_line=$(free | grep '^Mem:')
        total=$(echo $memory_line | awk '{print $2}')
        used=$(echo $memory_line | awk '{print $3}')
        free=$(echo $memory_line | awk '{print $4}')
        available=$(echo $memory_line | awk '{print $7}')

        if [[ $total -gt 0 ]]; then
            used_percent=$(( 100 * used / total ))
            free_percent=$(( 100 * free / total ))
            available_percent=$(( 100 * available / total ))

            echo ""
            echo -e "Memory Usage: ${RED}${used_percent}%${NC} used, ${GREEN}${available_percent}%${NC} available"
        fi
    elif [[ -r /proc/meminfo ]]; then
        # Fallback to /proc/meminfo
        total_kb=$(grep '^MemTotal:' /proc/meminfo | awk '{print $2}')
        available_kb=$(grep '^MemAvailable:' /proc/meminfo | awk '{print $2}')

        if [[ -n "$total_kb" && -n "$available_kb" ]]; then
            used_kb=$((total_kb - available_kb))
            used_percent=$((100 * used_kb / total_kb))
            available_percent=$((100 * available_kb / total_kb))

            total_gb=$((total_kb / 1024 / 1024))
            used_gb=$((used_kb / 1024 / 1024))
            available_gb=$((available_kb / 1024 / 1024))

            echo -e "Total Memory: ${BLUE}${total_gb}GB${NC}"
            echo -e "Used Memory: ${RED}${used_gb}GB (${used_percent}%)${NC}"
            echo -e "Available Memory: ${GREEN}${available_gb}GB (${available_percent}%)${NC}"
        fi
    fi
}

# Function to get disk usage
get_disk_usage() {
    print_header "DISK USAGE"

    if command -v df >/dev/null 2>&1; then
        echo -e "${CYAN}Filesystem breakdown:${NC}"
        df -h --exclude-type=tmpfs --exclude-type=devtmpfs --exclude-type=squashfs | while read line; do
            if [[ "$line" == "Filesystem"* ]]; then
                echo -e "${BLUE}$line${NC}"
            else
                # Color code based on usage percentage
                usage_percent=$(echo "$line" | awk '{print $5}' | sed 's/%//')
                if [[ "$usage_percent" =~ ^[0-9]+$ ]]; then
                    if [[ $usage_percent -gt 90 ]]; then
                        echo -e "${RED}$line${NC}"
                    elif [[ $usage_percent -gt 70 ]]; then
                        echo -e "${YELLOW}$line${NC}"
                    else
                        echo -e "${GREEN}$line${NC}"
                    fi
                else
                    echo "$line"
                fi
            fi
        done

        # Summary of total disk usage
        echo ""
        total_size=$(df -h --exclude-type=tmpfs --exclude-type=devtmpfs --exclude-type=squashfs --total | tail -1 | awk '{print $2}')
        total_used=$(df -h --exclude-type=tmpfs --exclude-type=devtmpfs --exclude-type=squashfs --total | tail -1 | awk '{print $3}')
        total_avail=$(df -h --exclude-type=tmpfs --exclude-type=devtmpfs --exclude-type=squashfs --total | tail -1 | awk '{print $4}')
        total_percent=$(df -h --exclude-type=tmpfs --exclude-type=devtmpfs --exclude-type=squashfs --total | tail -1 | awk '{print $5}')

        echo -e "${CYAN}Total Disk Usage Summary:${NC}"
        echo -e "Total Size: ${BLUE}${total_size}${NC}"
        echo -e "Used: ${RED}${total_used} (${total_percent})${NC}"
        echo -e "Available: ${GREEN}${total_avail}${NC}"
    fi
}

# Function to get top processes by CPU
get_top_cpu_processes() {
    print_header "TOP 5 PROCESSES BY CPU USAGE"

    if command -v ps >/dev/null 2>&1; then
        echo -e "${CYAN}%CPU   PID  COMMAND${NC}"
        ps aux --sort=-%cpu | head -6 | tail -5 | awk '{printf "%-6s %-6s %s\n", $3"%", $2, $11}' | while read line; do
            cpu_percent=$(echo "$line" | awk '{print $1}' | sed 's/%//')
            if [[ "$cpu_percent" =~ ^[0-9]+\.?[0-9]*$ ]] && (( $(echo "$cpu_percent > 50" | bc -l 2>/dev/null || echo 0) )); then
                echo -e "${RED}$line${NC}"
            elif [[ "$cpu_percent" =~ ^[0-9]+\.?[0-9]*$ ]] && (( $(echo "$cpu_percent > 20" | bc -l 2>/dev/null || echo 0) )); then
                echo -e "${YELLOW}$line${NC}"
            else
                echo -e "${GREEN}$line${NC}"
            fi
        done
    fi
}

# Function to get top processes by memory
get_top_memory_processes() {
    print_header "TOP 5 PROCESSES BY MEMORY USAGE"

    if command -v ps >/dev/null 2>&1; then
        echo -e "${CYAN}%MEM   PID  COMMAND${NC}"
        ps aux --sort=-%mem | head -6 | tail -5 | awk '{printf "%-6s %-6s %s\n", $4"%", $2, $11}' | while read line; do
            mem_percent=$(echo "$line" | awk '{print $1}' | sed 's/%//')
            if [[ "$mem_percent" =~ ^[0-9]+\.?[0-9]*$ ]] && (( $(echo "$mem_percent > 10" | bc -l 2>/dev/null || echo 0) )); then
                echo -e "${RED}$line${NC}"
            elif [[ "$mem_percent" =~ ^[0-9]+\.?[0-9]*$ ]] && (( $(echo "$mem_percent > 5" | bc -l 2>/dev/null || echo 0) )); then
                echo -e "${YELLOW}$line${NC}"
            else
                echo -e "${GREEN}$line${NC}"
            fi
        done
    fi
}

# Function to get system information (stretch goals)
get_system_info() {
    print_header "SYSTEM INFORMATION"

    # OS Version
    print_subheader "Operating System"
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        echo -e "OS: ${GREEN}${NAME} ${VERSION}${NC}"
        echo -e "Codename: ${BLUE}${VERSION_CODENAME:-N/A}${NC}"
    elif command -v lsb_release >/dev/null 2>&1; then
        os_info=$(lsb_release -d | cut -f2)
        echo -e "OS: ${GREEN}${os_info}${NC}"
    elif [[ -f /etc/redhat-release ]]; then
        os_info=$(cat /etc/redhat-release)
        echo -e "OS: ${GREEN}${os_info}${NC}"
    fi

    # Kernel version
    kernel_version=$(uname -r)
    echo -e "Kernel: ${BLUE}${kernel_version}${NC}"

    # Architecture
    arch=$(uname -m)
    echo -e "Architecture: ${CYAN}${arch}${NC}"

    # Uptime
    print_subheader "System Uptime"
    if command -v uptime >/dev/null 2>&1; then
        uptime_info=$(uptime -p 2>/dev/null || uptime | awk -F'up ' '{print $2}' | awk -F',' '{print $1}')
        echo -e "Uptime: ${GREEN}${uptime_info}${NC}"
    fi

    # Logged in users
    print_subheader "Logged In Users"
    if command -v who >/dev/null 2>&1; then
        logged_users=$(who | wc -l)
        echo -e "Currently logged in: ${YELLOW}${logged_users} users${NC}"
        if [[ $logged_users -gt 0 ]]; then
            echo -e "${CYAN}Active sessions:${NC}"
            who | while read line; do
                echo -e "  ${GREEN}${line}${NC}"
            done
        fi
    fi

    # Failed login attempts
    print_subheader "Recent Failed Login Attempts"
    failed_logins=0

    # Check different log files based on distribution
    for log_file in "/var/log/auth.log" "/var/log/secure" "/var/log/messages"; do
        if [[ -r "$log_file" ]]; then
            # Get failed login attempts from last 24 hours
            if command -v journalctl >/dev/null 2>&1; then
                failed_logins=$(journalctl --since="24 hours ago" | grep -c "authentication failure\|Failed password\|Invalid user" 2>/dev/null || echo 0)
            else
                # Fallback to parsing log files directly
                today=$(date +"%b %d")
                yesterday=$(date -d "yesterday" +"%b %d" 2>/dev/null || date -d "1 day ago" +"%b %d" 2>/dev/null || echo "")

                failed_today=$(grep "$today" "$log_file" 2>/dev/null | grep -c "authentication failure\|Failed password\|Invalid user" 2>/dev/null || echo 0)
                failed_yesterday=$(if [[ -n "$yesterday" ]]; then grep "$yesterday" "$log_file" 2>/dev/null | grep -c "authentication failure\|Failed password\|Invalid user" 2>/dev/null || echo 0; else echo 0; fi)
                failed_logins=$((failed_today + failed_yesterday))
            fi
            break
        fi
    done

    if [[ $failed_logins -gt 0 ]]; then
        echo -e "Failed login attempts (last 24h): ${RED}${failed_logins}${NC}"
    else
        echo -e "Failed login attempts (last 24h): ${GREEN}0${NC}"
    fi
}

# Main execution
main() {
    clear
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}       SERVER PERFORMANCE STATS        ${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo -e "Generated on: ${CYAN}$(date)${NC}"
    hostname_info=$(hostname 2>/dev/null || cat /proc/sys/kernel/hostname 2>/dev/null || echo "Unknown")
    echo -e "Hostname: ${GREEN}${hostname_info}${NC}"

    get_cpu_usage
    get_memory_usage
    get_disk_usage
    get_top_cpu_processes
    get_top_memory_processes
    get_system_info

    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${GREEN}        ANALYSIS COMPLETE              ${NC}"
    echo -e "${BLUE}========================================${NC}"
}

# Run the main function
main