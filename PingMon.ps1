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
    # 固定状态栏 (始终显示)
    # 状态行使用颜色区分
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
    
    # 显示事件日志 (保留最新记录)
    $startIndex = [Math]::Max(0, $eventLog.Count - 10)
    for ($i = $startIndex; $i -lt $eventLog.Count; $i++) {
        # 事件日志中的上线/下线也添加颜色
        if ($eventLog[$i] -match "Online") {
            Write-Host $eventLog[$i] -ForegroundColor Green
        } elseif ($eventLog[$i] -match "Offline") {
            Write-Host $eventLog[$i] -ForegroundColor Red
        } else {
            Write-Host $eventLog[$i]
        }
    }
    
    # 延迟信息单独显示在日志下方（实时刷新）
    Write-Host "----------------------"
    Write-Host "Current latency: $(if ($online -and $currentDelay) {"$currentDelay ms"} else {'N/A'})"
}

try {
    while ($true) {
        $ping = Test-Connection $ip -Count 1 -ErrorAction SilentlyContinue
        $currentDelay = $ping.ResponseTime  # 每次循环更新延迟值
        
        if ($ping) {
            $consecutiveFails = 0
            if (-not $online) {
                $online = $true
                $now = Get-Date
                $lastOnline = $now
                $eventLog.Add("[$($now.ToString('yyyy-MM-dd HH:mm:ss'))] Device Online.")
                Update-Status
            }
            else {
                # 在线状态持续时只刷新延迟
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
                Update-Status
            }
            elseif ($consecutiveFails -eq 5) {
                $now = Get-Date
                $logEntry = "[$($now.ToString('yyyy-MM-dd HH:mm:ss'))] failed with 5 times."
                $eventLog.Add($logEntry)
                $logEntry | Out-File $logFile -Append
                Update-Status
            }
            else {
                # 离线状态持续时刷新延迟显示
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