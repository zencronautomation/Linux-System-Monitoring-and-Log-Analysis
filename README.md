# 🐧 Linux System Monitoring and Log Analysis

A robust, Bash-based Linux monitoring system designed to collect system metrics, write timestamped logs, enforce configurable thresholds, and perform automated log analysis. 

Built and tested on **Debian 13 (Trixie)**, but compatible with Ubuntu 22.04/24.04 and other systemd-based distributions.

## 🌟 Real-World Features
Beyond standard CPU/RAM monitoring, this tool includes enterprise-grade checks to prevent silent VM crashes:
* **OOM (Out of Memory) Tracking:** Detects kernel-level OOM kills (crucial for low-RAM environments).
* **Inode Exhaustion Check:** Warns if the disk runs out of file pointers, even if GB space is available.
* **Systemd Health Check:** Identifies silently crashed background services.
* **Fallback Alerting:** Uses the native `logger` command to send critical alerts to `/var/log/syslog` if the disk is too full to write to the custom log file.
* **Automated Log Rotation:** Includes `logrotate` configuration to prevent disk exhaustion.

## 📁 Project Structure
```text
linux-system-monitor/
├── system_monitor.sh      # Main monitoring script
├── config.env             # Threshold configuration
├── logs/                  # Directory for output logs (ignored by Git)
│   └── system_monitor.log 
├── .gitignore             # Prevents logs from being committed
└── README.md              # Project documentation

