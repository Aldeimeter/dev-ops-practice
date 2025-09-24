# Server Stats Script

A comprehensive bash script to analyze basic server performance statistics on Linux systems.

## Features

### Core Statistics

- **CPU Usage** - Current CPU utilization percentage and load averages
- **Memory Usage** - Total, used, free memory with percentages
- **Disk Usage** - Filesystem usage with color-coded warnings
- **Top 5 CPU Processes** - Processes consuming most CPU resources
- **Top 5 Memory Processes** - Processes consuming most memory

### System Information

- Operating system version and kernel info
- System uptime
- Currently logged in users
- Recent failed login attempts (security monitoring)

## Requirements

- Linux operating system
- Bash shell
- Standard Linux utilities (top, free, df, ps, who)
- Read permissions for system files (/proc/stat, /proc/meminfo, etc.)

## Installation

1. Clone or download the script:

```bash
git clone <repository-url>
cd server-stats
```

2. Make the script executable:

```bash
chmod +x server-stats.sh
```

## Usage

### Run the script:

```bash
./server-stats.sh
```

### Run from anywhere (optional):

```bash
# Copy to a directory in your PATH
sudo cp server-stats.sh /usr/local/bin/server-stats
sudo chmod +x /usr/local/bin/server-stats

# Now you can run it from anywhere
server-stats
```

## Output

The script provides color-coded output with the following sections:

1. **Header** - Timestamp and hostname
2. **CPU Usage** - Current utilization and load averages
3. **Memory Usage** - RAM usage statistics with percentages
4. **Disk Usage** - Storage usage for all mounted filesystems
5. **Top CPU Processes** - 5 most CPU-intensive processes
6. **Top Memory Processes** - 5 most memory-intensive processes
7. **System Information** - OS details, uptime, users, and security info

### Color Coding

- 🔴 **Red** - High usage/warnings (CPU >50%, Memory >10%, Disk >90%)
- 🟡 **Yellow** - Medium usage (CPU >20%, Memory >5%, Disk >70%)
- 🟢 **Green** - Normal/low usage
- 🔵 **Blue** - Headers and informational text
- 🔷 **Cyan** - Subheaders and labels

## Compatibility

Tested on:

- Ubuntu/Debian
- CentOS/RHEL/Fedora
- Arch Linux
- SUSE

The script includes fallbacks for different distributions and handles cases where certain commands or log files may not be available.

## Permissions

Some features may require elevated permissions:

- **Failed login attempts** - Requires read access to `/var/log/auth.log` or `/var/log/secure`
- **System logs** - Some distributions restrict access to certain log files

Run with `sudo` if you need access to all features:

```bash
sudo ./server-stats.sh
```

## Example Output

```
========================================
       SERVER PERFORMANCE STATS
========================================
Generated on: Wed Sep 24 07:30:52 PM CEST 2025
Hostname: myserver

================================
CPU USAGE
================================
Current CPU Usage: 12.7%
Calculated CPU Usage: 12%
Load Average (1m, 5m, 15m): 2.53 2.42 2.37

================================
MEMORY USAGE
================================
               total        used        free      shared  buff/cache   available
Mem:            14Gi        10Gi       2.1Gi        67Mi       1.6Gi       4.8Gi
Swap:           15Gi        10Gi       4.3Gi

Memory Usage: 68% used, 31% available

... (additional sections)
```

## Troubleshooting

### Common Issues

1. **Permission denied errors**
   - Run with `sudo` for full access to system logs
   - Ensure script has execute permissions: `chmod +x server-stats.sh`

2. **Command not found errors**
   - The script includes fallbacks for most commands
   - Missing commands will be skipped gracefully

3. **No color output**
   - Some terminals don't support colors
   - Colors are automatically disabled in non-interactive environments

### Manual Testing

Test individual components:

```bash
# Test CPU usage
top -bn1 | grep "Cpu(s)"

# Test memory
free -h

# Test disk usage
df -h

# Test processes
ps aux --sort=-%cpu | head -6
ps aux --sort=-%mem | head -6
```

## Contributing

Feel free to submit issues or pull requests to improve the script's functionality or compatibility with different systems.

## License

This script is provided as-is for educational and administrative purposes.

