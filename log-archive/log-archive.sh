#!/bin/bash 

# Log Archive Script
#
# A bash script to compress all log files from a specified directory into
# a timestamped tar.gz archive for backup and storage purposes.
#
# Usage: ./log-archive.sh <path/to/logs>
#
# Features:
# - Finds all .log files in the specified directory
# - Creates timestamped archives in format: <dirname>_logs_archived_YYYYMMDD_HHMMSS.tar.gz
# - Automatically creates archived_logs/ directory for output
# - Color-coded output for better visibility
# - Input validation for directory existence and permissions
#

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

if [ $# -lt 1 ]; then
    echo -e "${RED}Usage: $0 <path/to/logs>${NC}"
    exit 1
fi

if ! [ -d "$1" ]; then
    echo -e "${RED}Directory doesn't exists${NC}"
    exit 1
fi

if ! [ -r "$1" ]; then
    echo -e "${RED}You don't have permission to read this directory${NC}"
    exit 1
fi

create_folder_for_logs() {
  if ! [ -d "./archived_logs" ]; then
    mkdir "archived_logs"
  fi
}

archive_logs() {
  echo -e "${BLUE} Compressing following log files"
  find $1 -name "*.log" -type f
  echo -e ${NC};
  log_file_name="$(basename $1)_logs_archived_$(date '+%Y%m%d_%H%M%S').tar.gz" 
  find $1 -name "*.log" -type f | tar -czf "archived_logs/${log_file_name}" $1 -T - 

  echo -e "${GREEN} log file was created at $PWD/archived_logs/${log_file_name}${NC}"
}

main() {
  create_folder_for_logs
  archive_logs $1
}

main $1
