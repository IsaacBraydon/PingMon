# Edit here to change the IP that you wanted to monitor.
$ip = "127.0.0.1"
# Default event log would saved at the location of this script.
$logFile = "ping_log.txt"

$online = $false
$lastOnline = $null
$lastOffline = $null
$consecutiveFails = 0
$eventLog = [System.Collections.Generic.List[string]]::new()
$currentDelay = $null

function Update-Status {
    Clear-Host
    if ($online) {
        Write-Host "Status: " -NoNewline
        Write-Host "Online" -ForegroundColor Green
    } else {
        Write-Host "Status: " -NoNewline
        Write-Host "Offline" -ForegroundColor Red
    }
    
    Write-Host "Last Online: $(if ($lastOnline) {$lastOnline.ToString('yyyy-MM-dd HH:mm:ss')} else {'N/A'})"
    Write-Host "Last Offline: $(if ($lastOffline) {$lastOffline.ToString('yyyy-MM-dd HH:mm:ss')} else {'N/A'})"
    Write-Host "--------------------- EventLog ---------------------"
    
    $startIndex = [Math]::Max(0, $eventLog.Count - 10)
    for ($i = $startIndex; $i -lt $eventLog.Count; $i++) {
        if ($eventLog[$i] -match "Online") {
            Write-Host $eventLog[$i] -ForegroundColor Green
        } elseif ($eventLog[$i] -match "Offline") {
            Write-Host $eventLog[$i] -ForegroundColor Red
        } else {
            Write-Host $eventLog[$i]
        }
    }
    
    Write-Host "----------------------"
    # 修复延迟显示逻辑
    Write-Host "Current latency: $(if ($online -and $null -ne $currentDelay) {"$currentDelay ms"} else {'N/A'})"
}

try {
    # 添加初始状态检测
    $ping = Test-Connection $ip -Count 1 -ErrorAction SilentlyContinue
    $online = [bool]$ping
    $currentDelay = $ping.ResponseTime
    if ($online) { $lastOnline = Get-Date } else { $lastOffline = Get-Date }
    Update-Status

    while ($true) {
        $ping = Test-Connection $ip -Count 1 -ErrorAction SilentlyContinue
        $currentDelay = $ping.ResponseTime
        
        if ($ping) {
            $consecutiveFails = 0
            if (-not $online) {
                $online = $true
                $now = Get-Date
                $lastOnline = $now
                $eventLog.Add("[$($now.ToString('yyyy-MM-dd HH:mm:ss'))] Device Online.")
                $eventLog[-1] | Out-File $logFile -Append
                Update-Status
            }
            else {
                Update-Status
            }
        }
        else {
            $consecutiveFails++
            if ($online) {
                $online = $false
                $now = Get-Date
                $lastOffline = $now
                $eventLog.Add("[$($now.ToString('yyyy-MM-dd HH:mm:ss'))] Device Offline.")
                $eventLog[-1] | Out-File $logFile -Append
                Update-Status
            }
            elseif ($consecutiveFails -eq 5) {
                $now = Get-Date
                $logEntry = "[$($now.ToString('yyyy-MM-dd HH:mm:ss'))] Connection failed with 5 times."
                $eventLog.Add($logEntry)
                $logEntry | Out-File $logFile -Append
                Update-Status
            }
            else {
                $currentDelay = $null
                Update-Status
            }
        }
        Start-Sleep -Seconds 1
    }
}
finally {
    Write-Host "`nMonitor Stopped."
}
