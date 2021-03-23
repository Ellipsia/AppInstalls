$ApplicationList =@("*Alertus*")
$Results = @()
$ClassesRegLocation = "HKLM:Software\Classes\Installer\Products"
$UninstRegLocations = @("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall","HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall")
$MSI = "alertus-desktopAlert_DotNet4.5_v5.3.3.0.msi"
$InstallPath = "`"" + $PSScriptRoot + "\$MSI" + "`""
$Logs = "`"C:\Windows\Temp\Alertus.log`""

$MSIArguments = @(
    '/i'
    $InstallPath
    '/qn'    
    '/L*v'
    $Logs
    'REBOOT=REALLYSUPPRESS'
    )

Try{
    $IssueReported = $null

    $Install = Start-Process "MsiExec.exe" -ArgumentList $MSIArguments -NoNewWindow -ErrorAction Stop -ErrorVariable $IssueReported -PassThru
    $Install | Wait-Process -Timeout 120 -ErrorAction SilentlyContinue -ErrorVariable $IssueReported
    
    If ($IssueReported -or $Install.ExitCode){
        Stop-Process -Name "msi*" -Force -ErrorAction SilentlyContinue
        Exit Try
    }
}

Catch{
    #Clean up both HKLM are of the uninstall portion of the registry
    foreach($Location in $UninstRegLocations)
    {
        foreach($Application in $ApplicationList)
        {
            $Results += (Get-ChildItem -Path $Location | Get-ItemProperty | Where-Object {$_.DisplayName -like $Application} | Select-Object -Property DisplayName,PSChildName)
        }
    }
    
    foreach($UnInstRegRemoval in $Results)
        {
            $UninstCleanup = Join-path $UninstRegLocations $UnInstRegRemoval.PSChildName
            Remove-Item $UninstCleanup -Recurse -Force -ErrorAction SilentlyContinue
        }

    #Clean up HKCR area of the installs
    foreach($Location in $ClassesRegLocation)
        {
            foreach($Application in $ApplicationList)
            {
                $Results += (Get-ChildItem -Path $Location | Get-ItemProperty | Where-Object {$_.ProductName -like $Application} | Select-Object -Property ProductName,PSChildName)
            }
        }
    
    foreach($ClassesRegRemoval in $Results)
        {
            $ClassesCleanup = Join-path $ClassesRegLocation $ClassesRegRemoval.PSChildName
            Remove-Item $ClassesCleanup -Recurse -Force -ErrorAction SilentlyContinue
                    
        }

        #Try the install again
        $Install = Start-Process "MsiExec.exe" -ArgumentList "$MSIArguments"  -Wait -NoNewWindow -ErrorAction Stop -PassThru

        Return $Install.ExitCode
}

      