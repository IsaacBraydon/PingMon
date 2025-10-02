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
    Write-Host "--------------------- Event Log ---------------------"
    
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
    # 显示当前延迟
    Write-Host "Current latency: $(if ($online -and $null -ne $currentDelay) {"$currentDelay ms"} else {'N/A'})"
    
    # 添加0 ms延迟警告
    if ($online -and $null -ne $currentDelay -and $currentDelay -eq 0) {
        Write-Host ""
        Write-Host "WARNING: 0 ms latency detected!" -ForegroundColor Red
        Write-Host "This may indicate:" -ForegroundColor Yellow
        Write-Host "- Local loopback interface (127.0.0.1 or localhost)" -ForegroundColor Yellow
        Write-Host "- VPN connection affecting monitoring" -ForegroundColor Yellow
        Write-Host "- Network configuration issues" -ForegroundColor Yellow
        Write-Host "Monitoring accuracy may be affected." -ForegroundColor Yellow
    }
}

try {
    # 初始状态检测
    $ping = Test-Connection $ip -Count 1 -ErrorAction SilentlyContinue
    $online = [bool]$ping
    $currentDelay = $ping.ResponseTime
    if ($online) { 
        $lastOnline = Get-Date 
        # 初始状态也检查0ms警告
        if ($currentDelay -eq 0) {
            $eventLog.Add("[$((Get-Date).ToString('yyyy-MM-dd HH:mm:ss'))] WARNING: Initial connection has 0ms latency!")
        }
    } else { 
        $lastOffline = Get-Date 
    }
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
                
                # 上线时检查是否为0ms延迟
                $logEntry = if ($currentDelay -eq 0) {
                    "[$($now.ToString('yyyy-MM-dd HH:mm:ss'))] Device Online. WARNING: 0ms latency!"
                } else {
                    "[$($now.ToString('yyyy-MM-dd HH:mm:ss'))] Device Online."
                }
                
                $eventLog.Add($logEntry)
                $logEntry | Out-File $logFile -Append
                Update-Status
            }
            else {
                # 持续在线时也记录0ms延迟事件
                if ($currentDelay -eq 0 -and $eventLog[-1] -notmatch "0ms latency") {
                    $logEntry = "[$((Get-Date).ToString('yyyy-MM-dd HH:mm:ss'))] WARNING: 0ms latency detected!"
                    $eventLog.Add($logEntry)
                    $logEntry | Out-File $logFile -Append
                }
                Update-Status
            }
        }
        else {
            $consecutiveFails++
            if ($online) {
                $online = $false
                $now = Get-Date
                $lastOffline = $now
                $logEntry = "[$($now.ToString('yyyy-MM-dd HH:mm:ss'))] Device Offline."
                $eventLog.Add($logEntry)
                $logEntry | Out-File $logFile -Append
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
