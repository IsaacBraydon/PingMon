# PingMon
PingMon is a lightweight PowerShell-based tool for continuous network monitoring through ICMP ping requests. It provides real-time status updates with color-coded indicators and maintains an event log of connectivity changes.
# PingMon - Real-time Network Monitoring Tool

## Key Features

- ✅ **Real-time Status Monitoring**: Continuously checks target IP availability
- 🎨 **Color-coded Status**: Green for online, red for offline
- ⏱ **Live Latency Updates**: Refreshes ping latency after each test
- 📅 **Timestamp Tracking**: Records exact time of last online/offline events
- 📝 **Event Logging**: Automatically logs status changes
- 📁 **Persistent Logging**: Saves critical events to file
- 📊 **Clean Interface**: Displays events with latency information

## Getting Started

### Basic Usage
1. Clone repository or download script
2. Run with PowerShell:
   powershell
   .\PingMon.ps1

3. Monitoring interface will appear automatically

### Configuration
Edit variables at script start:
powershell
$ip = "192.168.31.102"    # Target IP to monitor
$logFile = "ping_log.txt" # Custom log file path


### Interface Overview

Status: Online (green) / Offline (red)
Last Online: 2023-10-05 14:30:22
Last Offline: 2023-10-05 14:25:15
--------------------- Event Log ---------------------
[2023-10-05 14:25:15] Offline (red)
[2023-10-05 14:30:22] Online (green)
[2023-10-05 14:32:45] 5 consecutive failures

Current Latency: 24 ms


### Stopping Monitoring
Press `Ctrl + C` to exit

## Requirements
- Windows PowerShell 5.1+
- Windows OS

## License
Distributed under the MIT License. See `LICENSE` for more information.

---
**Simplified network monitoring** - PingMon helps you quickly identify connectivity issues
