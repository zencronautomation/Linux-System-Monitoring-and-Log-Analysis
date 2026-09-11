# 🐧 Linux System Monitoring and Log Analysis

[![Bash](https://img.shields.io/badge/Bash-Script-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Linux](https://img.shields.io/badge/Linux-Debian/Ubuntu-FCC624?style=for-the-badge&logo=linux&logoColor=black)](https://www.debian.org/)

A robust, Bash-based Linux monitoring system designed to collect system metrics, write timestamped logs, enforce configurable thresholds, and assist with basic log analysis. Built to prevent silent failures and ensure system reliability.

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

| Goal | Command |
|------|---------|
| View live log updates | `tail -f logs/system_monitor.log` |
| Find triggered warnings | `grep -i 'warning' logs/system_monitor.log` |
| Find specific errors | `grep -i 'error' logs/system_monitor.log` |
| Check system journal (last hour) | `journalctl --since 'i hour ago'` |
| Check system journal (warnings only) | `journalctl -p warning -n 30 --no-pager` |

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

| Issue | Solution |
|-------|----------|
| Permission denied | Run `chmod +x system_monitor.sh` |
| No journal output | Run `journalctl -p warning -n 30 --no-pager` to verify systemd logging is active. |
| Log not created | Verify `config.env` exists and check directory permissions: `ls -ld ~/linux-system-monitor/logs` |
| CPU parsing differs | Linux distributions format `top` differently. This script uses `vmstat` for reliable parsing, but inspect `top -bn1` and adjust the `awk` expression if using a highly customized distro. |
| Test a Warning | Temporarily lower `CPU_THRESHOLD-1` in `config.env`, run `./system_monitor.sh`, and verify the WARNING appears in the log. |

🔗 Source Code
To keep this documentation clean and readable, the full Bash script is not embedded here. You can view, download, or audit the complete source code directly in the repository:
👉 View system_monitor.sh Source Code

Built for reliability. Tested on Debian 13 & Ubuntu LTS.
