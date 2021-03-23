$ScheduledTaskAction = @"
Invoke-Command -Scriptblock {

Remove-ItemProperty -Path 'HKLM:SOFTWARE\Policies\Microsoft\Windows Defender' -Name 'DisableAntiSpyware' -Force -ErrorAction Continue;
Start-Service WinDefend;
Stop-Service BITS -Force;
Stop-Service wuauserv -Force;
Stop-Service AppIDSvc -Force;
Stop-Service CryptSvc -Force;
Remove-Item `$env:SystemRoot\system32\catroot2 -Force -Recurse -ErrorAction Continue;
Remove-Item `$env:SystemRoot\SoftwareDistribution -Force -Recurse -ErrorAction Continue;
Start-Service BITS;
Start-Service wuauserv;
Start-Service CryptSvc;
Start-Service AppIDSvc;
Unregister-ScheduledTask -TaskName 'RemedyWindowsDefender' -Confirm:`$false

}
"@

New-ItemProperty -Path "HKLM:SOFTWARE\Policies\Microsoft\Windows Defender" -Name DisableAntiSpyware -Value 1 -PropertyType DWORD -Force

# How/What will this run
$action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument "-nologo -executionpolicy bypass -NoProfile -command `"& $ScheduledTaskAction`""

# What triggers the event
$trigger = New-ScheduledTaskTrigger -AtStartup

# Create scheduled task
Register-ScheduledTask -Action $Action -Trigger $trigger -TaskName "RemedyWindowsDefender" -Description "Upon next reboot this will remedy Windows Defender" -Force -RunLevel Highest -User SYSTEM