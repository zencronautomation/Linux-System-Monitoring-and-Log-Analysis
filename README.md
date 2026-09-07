# 🐧 Linux System Monitoring and Log Analysis

[![Bash](https://img.shields.io/badge/Bash-Script-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Linux](https://img.shields.io/badge/Linux-Debian/Ubuntu-FCC624?style=for-the-badge&logo=linux&logoColor=black)](https://www.debian.org/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)](LICENSE)

A robust, Bash-based Linux monitoring system designed to collect system metrics, write timestamped logs, enforce configurable thresholds, and assist with basic log analysis. Built to prevent silent VM crashes in constrained environments.

---

## 🎯 Project Purpose
This project fulfills the core requirements of enterprise system monitoring by:
1. Collecting **CPU, memory, disk, uptime, load average, and top process** information.
2. Writing **timestamped logs** to a dedicated file.
3. Checking **configurable thresholds** and raising clear warnings.
4. Assisting with **basic log analysis** using standard Linux utilities.
5. Running **automatically** in the background via `cron`.

---

## ✨ Key Features
Beyond standard metric collection, this monitor includes **real-world production safeguards**:
- **OOM (Out of Memory) Tracking**: Detects kernel-level OOM kills (crucial for low-RAM environments).
- **Inode Exhaustion Check**: Warns if the disk runs out of file pointers, even if GB space is available.
- **Systemd Health Check**: Identifies silently crashed background services (`systemctl --failed`).
- **Fallback Alerting**: Uses the native `logger` command to send critical alerts to `/var/log/syslog` if the disk is too full to write to the custom log file.
- **Automated Log Rotation**: Ready-to-use `logrotate` configuration to prevent disk exhaustion.

---

## 📁 Project Structure
```text
linux-system-monitor/
├── system_monitor.sh      # Main monitoring script (View Source Below 🔗)
├── config.env             # Threshold configuration
├── logs/                  # Directory for output logs (ignored by Git)
│   └── system_monitor.log 
├── .gitignore             # Prevents logs and temp files from being committed
└── README.md              # This documentation file
