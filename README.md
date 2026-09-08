# 🐧 Linux System Monitoring and Log Analysis

[![Bash](https://img.shields.io/badge/Bash-Script-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Linux](https://img.shields.io/badge/Linux-Debian/Ubuntu-FCC624?style=for-the-badge&logo=linux&logoColor=black)](https://www.debian.org/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)](LICENSE)

A robust, Bash-based Linux monitoring system designed to collect system metrics, write timestamped logs, enforce configurable thresholds, and assist with basic log analysis. Built to prevent silent VM[...] 

---

## 🎯 Project Purpose
This project fulfills the core requirements of enterprise system monitoring by:
1. Collecting **CPU, memory, disk, uptime, load average, and top process** information.
2. Writing **timestamped logs** to a dedicated file.
3. Checking **configurable thresholds** and raising clear warnings.
4. Assisting with **basic log analysis** using standard Linux utilities.
5. Running **automatically** in the background via `cron`.

---

⚙️ Requirements
OS: Ubuntu Server 22.04/24.04 LTS or Debian 12/13 (Trixie)
Resources: 2 CPU cores, 2–4 GB RAM, 10 GB free disk recommended
Dependencies: bash, cron, procps, logrotate, systemd/journalctl
Utilities Used: uptime, free, df, ps, vmstat, awk, grep, sed, date, hostname, journalctl, tail

🚀 Setup & Installation
Clone the repository:
```bash
git clone https://github.com/zencronautomation/Linux-System-Monitoring-and-Log-Analysis.git
cd Linux-System-Monitoring-and-Log-Analysis
```
Make the script executable:
```bash
chmod +x system_monitor.sh
```
Create the logs directory (one-time):
```bash
mkdir -p logs
```
Run the monitor manually to test:
```bash
./system_monitor.sh
```

⚙️ Configuration
Thresholds are managed in a separate, easy-to-edit file. Copy the example and edit as needed:
```bash
cp config.env.example config.env
# then edit config.env
```
Example values in `config.env.example` (see file in repo).

📊 Log Analysis Workflow
Use these standard Linux commands to analyze system health and troubleshoot issues based on the generated logs:
See the pinned quick-commands file for these shortcuts:
- table-d3e6a728-8685-4f0b-b4cd-0bfb686d2545.csv
  https://github.com/zencronautomation/Linux-System-Monitoring-and-Log-Analysis/blob/main/table-d3e6a728-8685-4f0b-b4cd-0bfb686d2545.csv

Troubleshooting table:
- table-d3e6a728-8685-4f0b-b4cd-0bfb686d2545 (1).csv
  https://github.com/zencronautomation/Linux-System-Monitoring-and-Log-Analysis/blob/main/table-d3e6a728-8685-4f0b-b4cd-0bfb686d2545%20(1).csv

Analysis Best Practices:
- Look for repeated warnings in the log file.
- Check for high resource utilization spikes.
- Identify processes consuming unusual CPU/Memory resources.
- Compare system journalctl warnings with resource events in the monitor log.

🕐 Automatic Scheduling (Cron)
To run the monitor automatically every 5 minutes, add it to your user's crontab:

Open the crontab editor:
```bash
crontab -e
```

Add the following line at the bottom (replace $HOME with your actual path if needed). This example ensures the script runs from the repo directory, uses /bin/bash, and appends stdout/stderr to a cron log:
```cron
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

*/5 * * * * cd $HOME/Linux-System-Monitoring-and-Log-Analysis && /bin/bash ./system_monitor.sh >> $HOME/Linux-System-Monitoring-and-Log-Analysis/logs/cron_run.log 2>&1
```

Verify the job is scheduled:
```bash
crontab -l
```

🧪 Testing & Troubleshooting
See the troubleshooting CSV in the repository for common issues:
https://github.com/zencronautomation/Linux-System-Monitoring-and-Log-Analysis/blob/main/table-d3e6a728-8685-4f0b-b4cd-0bfb686d2545%20(1).csv

🔗 Source Code
To keep this documentation clean and readable, the full Bash script is not embedded here. You can view, download, or audit the complete source code directly in the repository:
👉 View system_monitor.sh Source Code

Built for reliability. Tested on Debian 13 & Ubuntu LTS.
