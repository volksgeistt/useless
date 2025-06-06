> [!TIP]
> **To fully remove ProcessKiller from startup:**
> 
> 1. **Delete the startup file:**
>    ```powershell
>    Remove-Item "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\ProcessKiller.ps1"
>    ```
> 
> 2. **Remove the registry entry:**
>    ```powershell
>    Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "ProcessKiller"
>    ```
> 
> 3. **Remove the scheduled task (if any):**
>    ```powershell
>    Unregister-ScheduledTask -TaskName "ProcessKiller" -Confirm:$false
>    ```
