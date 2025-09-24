# DevOps Practice Repository

This repository contains DevOps practice projects and tasks for skill development and learning.

## Projects

### 📊 [Server Stats](./server-stats/)

A comprehensive bash script to analyze server performance statistics on Linux systems.

**Features:**

- CPU usage monitoring and load averages
- Memory usage analysis with color-coded warnings
- Disk usage reporting for all mounted filesystems
- Top CPU and memory consuming processes
- System information (OS, uptime, users, security logs)

**Project URL:** https://roadmap.sh/projects/server-stats

### 📁 [Log Archive](./log-archive/)

A bash script to compress and archive log files from any directory into timestamped tar.gz files.

**Features:**

- Automatic log file discovery (.log extension)
- Timestamped archive creation with organized storage
- Smart processing - only creates archives when log files exist
- Color-coded output with comprehensive error handling
- Input validation for directory existence and permissions

**Project URL:** https://roadmap.sh/projects/log-archive-tool

### 📈 [NGINX Log Analyzer](./nginx-log-analyzer/)

A comprehensive bash script to analyze NGINX access logs and extract meaningful insights about web traffic patterns.

**Features:**

- Top N analysis for IP addresses, requested paths, status codes, and user agents
- Compressed log file support (.gz files)
- Configurable result count with performance optimization
- Log format validation and comprehensive error handling
- Color-coded output with detailed traffic pattern insights

**Project URL:** https://roadmap.sh/projects/nginx-log-analyser

## Getting Started

Each project directory contains its own README with detailed setup and usage instructions.

```bash
# Clone the repository
git clone <repository-url>
cd DevOps

# Navigate to a specific project
cd server-stats
```

## Project Structure

```
DevOps/
├── README.md                    # This file
├── server-stats/                # Server performance monitoring script
│   ├── README.md                # Project-specific documentation
│   └── server-stats.sh          # Main bash script
├── log-archive/                 # Log archiving and compression tool
│   ├── README.md                # Project-specific documentation
│   ├── log-archive.sh           # Main bash script
│   └── archived_logs/           # Output directory (auto-created)
└── nginx-log-analyzer/          # NGINX access log analysis tool
    ├── README.md                # Project-specific documentation
    └── nginx-log-analyzer.sh    # Main bash script
```

## Requirements

- Linux operating system
- Bash shell
- Standard Linux utilities (varies by project)

## Contributing

This is a personal practice repository for DevOps skill development. Each project follows the challenges from [roadmap.sh](https://roadmap.sh/).
