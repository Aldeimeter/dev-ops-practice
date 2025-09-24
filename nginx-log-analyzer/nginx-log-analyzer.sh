#!/bin/bash

# NGINX Log Analyzer
# Description: Analyzes NGINX access logs to extract useful statistics including:
#   - Top N IP addresses with the most requests
#   - Top N most requested paths
#   - Top N response status codes
#   - Top N user agents
# Usage: ./nginx-log-analyzer.sh <path/to/nginx-access.log> [number_of_results]
# Supports both regular and compressed (.gz) log files

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # No Color

# Default number of top results to show
readonly DEFAULT_TOP_COUNT=5

# Show usage information
show_usage() {
    echo -e "${YELLOW}Usage: $0 <path/to/nginx-access.log> [number_of_results]${NC}"
    echo -e "${YELLOW}Example: $0 /var/log/nginx/access.log 10${NC}"
    echo -e "${YELLOW}Supports both regular and compressed (.gz) log files${NC}"
}

# Validate input parameters
validate_input() {
    if [ $# -lt 1 ]; then
        echo -e "${RED}Error: Missing required argument${NC}"
        show_usage
        exit 1
    fi

    local log_file="$1"

    if [ ! -f "$log_file" ]; then
        echo -e "${RED}Error: Log file '$log_file' does not exist${NC}"
        exit 1
    fi

    if [ ! -r "$log_file" ]; then
        echo -e "${RED}Error: You don't have permission to read file '$log_file'${NC}"
        exit 1
    fi

    # Check if file is empty
    if [ ! -s "$log_file" ]; then
        echo -e "${RED}Error: Log file '$log_file' is empty${NC}"
        exit 1
    fi
}

# Validate that the file appears to be an NGINX access log
validate_log_format() {
    local log_file="$1"
    local sample_line

    # Get first non-empty line
    sample_line=$(get_file_content "$log_file" | head -1 | grep -v '^$' || true)

    if [ -z "$sample_line" ]; then
        echo -e "${RED}Error: Could not read any content from log file${NC}"
        exit 1
    fi

    # Basic validation: check if line has typical NGINX log structure (IP, timestamp, request, status)
    if ! echo "$sample_line" | grep -qE '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}.*\[.*\].*".*".*[0-9]{3}'; then
        echo -e "${YELLOW}Warning: File may not be a standard NGINX access log format${NC}"
        echo -e "${YELLOW}Sample line: $sample_line${NC}"
        echo -e "${YELLOW}Continuing anyway...${NC}"
    fi
}

# Handle both regular and compressed files
get_file_content() {
    local log_file="$1"

    if [[ "$log_file" == *.gz ]]; then
        if ! command -v zcat >/dev/null 2>&1; then
            echo -e "${RED}Error: zcat command not found. Cannot read compressed files.${NC}"
            exit 1
        fi
        zcat "$log_file"
    else
        cat "$log_file"
    fi
}

# Extract IP addresses from log entries
extract_ips() {
    awk '{print $1}'
}

# Extract request paths from log entries
extract_request_paths() {
    awk '{match($0, /"[A-Z]+ ([^ ]+)/, arr); if (arr[1]) print arr[1]}'
}

# Extract HTTP status codes from log entries
extract_status_codes() {
    awk '{for(i=1;i<=NF;i++) if($i ~ /^[1-5][0-9][0-9]$/) {print $i; break}}'
}

# Extract user agents from log entries
extract_user_agents() {
    awk -F'"' '{if (NF >= 6) print $6}' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

# Sort data and get top N results
sort_and_get_top() {
    local count="$1"
    sort | uniq -c | sort -nr | head -"$count"
}

# Format output with proper alignment
format_output() {
    awk '{printf "%8d requests - %s\n", $1, substr($0, index($0,$2))}'
}

# Display analysis results
show_analysis() {
    local log_file="$1"
    local top_count="$2"
    local file_content

    echo -e "${GREEN}=== NGINX Log Analysis Results ===${NC}"
    echo -e "${BLUE}Log file: $log_file${NC}"
    echo -e "${BLUE}Showing top $top_count results for each category${NC}\n"

    # Read file content once and store in variable
    file_content=$(get_file_content "$log_file")

    if [ -z "$file_content" ]; then
        echo -e "${RED}Error: No content found in log file${NC}"
        exit 1
    fi

    echo -e "${CYAN}Top $top_count IP addresses with the most requests:${NC}"
    echo "$file_content" | extract_ips | sort_and_get_top "$top_count" | format_output
    echo

    echo -e "${CYAN}Top $top_count most requested paths:${NC}"
    echo "$file_content" | extract_request_paths | sort_and_get_top "$top_count" | format_output
    echo

    echo -e "${CYAN}Top $top_count response status codes:${NC}"
    echo "$file_content" | extract_status_codes | sort_and_get_top "$top_count" | format_output
    echo

    echo -e "${CYAN}Top $top_count user agents:${NC}"
    echo "$file_content" | extract_user_agents | sort_and_get_top "$top_count" | format_output
    echo
}

# Main function
main() {
    local log_file="$1"
    local top_count="${2:-$DEFAULT_TOP_COUNT}"

    # Validate that top_count is a positive integer
    if ! [[ "$top_count" =~ ^[1-9][0-9]*$ ]]; then
        echo -e "${RED}Error: Number of results must be a positive integer${NC}"
        show_usage
        exit 1
    fi

    validate_input "$@"
    validate_log_format "$log_file"
    show_analysis "$log_file" "$top_count"

    echo -e "${GREEN}Analysis completed successfully!${NC}"
}

# Execute main function with all arguments
main "$@"

