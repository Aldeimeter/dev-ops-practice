# Log Archive Script

A simple bash script to compress and archive log files from any directory into timestamped tar.gz files for backup and storage.

## Features

### Core Functionality

- **Log File Discovery** - Automatically finds all .log files in the specified directory
- **Timestamped Archives** - Creates archives with format: `<dirname>_logs_archived_YYYYMMDD_HHMMSS.tar.gz`
- **Organized Storage** - Archives are saved in an `archived_logs/` directory
- **Color-Coded Output** - Visual feedback with color-coded messages
- **Input Validation** - Checks directory existence and read permissions
- **Smart Processing** - Only creates archives when log files are found

### Archive Management

- Automatic creation of output directory if it doesn't exist
- Preserves directory structure within archives
- Non-destructive - original log files remain untouched
- Clear feedback on archive location and file count

## Requirements

- Linux/Unix operating system
- Bash shell
- Standard utilities: `find`, `tar`, `basename`, `date`
- Read permissions for the target log directory

## Installation

1. Clone or download the script:

```bash
git clone <repository-url>
cd log-archive
```

2. Make the script executable:

```bash
chmod +x log-archive.sh
```

## Usage

### Basic Usage:

```bash
./log-archive.sh /path/to/logs
```

### Examples:

```bash
# Archive logs from /var/log
./log-archive.sh /var/log

# Archive application logs
./log-archive.sh ./logs

# Archive nginx logs
./log-archive.sh /var/log/nginx
```

### Run from anywhere (optional):

```bash
# Copy to a directory in your PATH
sudo cp log-archive.sh /usr/local/bin/log-archive
sudo chmod +x /usr/local/bin/log-archive

# Now you can run it from anywhere
log-archive /path/to/logs
```

## Output

The script provides color-coded feedback and creates archives with the following structure:

### Archive Naming Convention:

```
<directory-name>_logs_archived_YYYYMMDD_HHMMSS.tar.gz
```

### Example Output:

```bash
$ ./log-archive.sh /var/log/nginx

 Compressing following log files
/var/log/nginx/access.log
/var/log/nginx/error.log

 log file was created at /home/user/log-archive/archived_logs/nginx_logs_archived_20250924_203820.tar.gz
```

### Color Coding:

- 🔵 **Blue** - Informational messages and file listings
- 🟢 **Green** - Success messages and completion notifications
- 🟡 **Yellow** - Warning messages (e.g., no log files found)
- 🔴 **Red** - Error messages and validation failures
- 🔷 **Cyan** - Usage instructions

## Archive Structure

Archives maintain the original directory structure:

```
nginx_logs_archived_20250924_203820.tar.gz
└── var/log/nginx/
    ├── access.log
    └── error.log
```

## Error Handling

The script includes comprehensive error checking:

1. **Missing arguments** - Shows usage information
2. **Non-existent directory** - Validates directory exists
3. **Permission issues** - Checks read permissions before proceeding
4. **Empty directories** - Handles directories with no .log files gracefully

### Common Issues:

1. **Permission denied**

   ```bash
   # For system directories, you may need sudo
   sudo ./log-archive.sh /var/log
   ```

2. **Directory not found**

   ```bash
   # Ensure the path is correct
   ls -la /path/to/logs
   ```

3. **No log files found**
   - The script will display a warning and exit without creating an archive
   - Check if files have .log extension or are in subdirectories

## Compatibility

Tested on:

- Ubuntu/Debian
- CentOS/RHEL/Fedora
- Arch Linux
- macOS (with bash)

The script uses standard POSIX utilities and should work on most Unix-like systems.

## Use Cases

- **System Administration** - Regular backup of system logs
- **Application Maintenance** - Archiving application logs before rotation
- **Development** - Backing up test logs and debug output
- **Compliance** - Creating timestamped archives for audit trails
- **Disk Space Management** - Compressing old logs to save space

## Example Workflows

### Daily Log Archiving:

```bash
# Create a cron job for daily archiving
0 2 * * * /usr/local/bin/log-archive /var/log/myapp
```

### Pre-deployment Cleanup:

```bash
# Archive logs before deploying new version
./log-archive.sh ./logs
rm -f ./logs/*.log
```

### Batch Processing Multiple Directories:

```bash
#!/bin/bash
for dir in /var/log/nginx /var/log/apache2 /var/log/mysql; do
    if [[ -d "$dir" ]]; then
        ./log-archive.sh "$dir"
    fi
done
```

## Contributing

Feel free to submit issues or pull requests to improve the script's functionality or add new features.

## Project URL

This project is based on a challenge from: https://roadmap.sh/projects/log-archive-tool

## License

This script is provided as-is for educational and administrative purposes.
