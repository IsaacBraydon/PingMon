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
    # �̶�״̬�� (ʼ����ʾ)
    # ״̬��ʹ����ɫ����
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
    
    # ��ʾ�¼���־ (�������¼�¼)
    $startIndex = [Math]::Max(0, $eventLog.Count - 10)
    for ($i = $startIndex; $i -lt $eventLog.Count; $i++) {
        # �¼���־�е�����/����Ҳ�����ɫ
        if ($eventLog[$i] -match "Online") {
            Write-Host $eventLog[$i] -ForegroundColor Green
        } elseif ($eventLog[$i] -match "Offline") {
            Write-Host $eventLog[$i] -ForegroundColor Red
        } else {
            Write-Host $eventLog[$i]
        }
    }
    
    # �ӳ���Ϣ������ʾ����־�·���ʵʱˢ�£�
    Write-Host "----------------------"
    Write-Host "Current latency: $(if ($online -and $currentDelay) {"$currentDelay ms"} else {'N/A'})"
}

try {
    while ($true) {
        $ping = Test-Connection $ip -Count 1 -ErrorAction SilentlyContinue
        $currentDelay = $ping.ResponseTime  # ÿ��ѭ�������ӳ�ֵ
        
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
                # ����״̬����ʱֻˢ���ӳ�
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
                # ����״̬����ʱˢ���ӳ���ʾ
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