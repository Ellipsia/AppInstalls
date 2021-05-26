<#
.Synopsis
    Detects and removes bunk DCM installs
.DESCRIPTION
    Searches WMI to verify it is intact due to build upgrades.  If not, remediate
.EXAMPLE
   
#>

Try{
    # What software to check for
    $SoftwareCheck = "*Dell Command | Monitor*"
    $CheckSW = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*, `
    HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* `
    -Name DisplayName -ErrorAction SilentlyContinue | Where-Object {$_.DisplayName -like $SoftwareCheck} -ErrorAction SilentlyContinue
    
    #uninstall all found versions
    ForEach ($ver in $CheckSW.PSChildName) {  
        Start-Process -FilePath MSIExec.exe -ArgumentList "/x $ver /qn /norestart /l*v `"$env:windir\Temp\DCM_Uninstall.log`"" -Wait -ErrorAction SilentlyContinue
    }

    #Force hardware inventory
    Start-Process WMIC -ArgumentList "/namespace:\\root\ccm path sms_client CALL TriggerSchedule `"{00000000-0000-0000-0000-000000000001}`" /NOINTERACTIVE"
}
Catch{
    $Time=Get-Date
    "$Time DCM Uninstall failed" | Out-File "$env:windir\temp\DCM_Uninstall.log"
}