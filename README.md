# PingMon

PingMon is a lightweight PowerShell-based tool for continuous network monitoring through ICMP ping requests. It provides real-time status updates with color-coded indicators and maintains an event log of connectivity changes.

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
2. Change the IP that you wanted to monitor
   
   2.1 Right-click and choose 'Edit' / Drag the script to Notepad  
   2.2 Edit `$ip` line to set the IP that you wanted to monitor  
   2.3 Save the script & close the Window
   
3. Run the script:
   
   **Option 1: Right-Click**  
     1. Right-Click on the script  
     2. Click on 'Run with PowerShell' option  
     3. Confirm the pop-up window of the Security Warning
   
   **Option 2: PowerShell Command**  
   powershell
   .\PingMon.ps1

   
4. Monitoring interface will appear automatically

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
- Windows 10 or upper version

## License
Distributed under the MIT License. See `LICENSE` for more information.
