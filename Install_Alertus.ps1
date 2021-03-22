$applicationlist =@("*Alertus*")
$results = @()
$classesreglocation = "HKLM:Software\Classes\Installer\Products"
$uninstreglocations = @("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall","HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall")
$MSI = "alertus-desktopAlert_DotNet4.5_v5.3.3.0.msi"
$InstallPath = "`"" + $PSScriptRoot + "\$MSI" + "`""
$logs = "`"C:\Windows\Temp\Alertus.log`""
$CurrentFaultyInstall = "6B34A75E1C25A74488D065EE7D98D06B"

$MSIArguments = @(
    '/i'
    $InstallPath
    '/qb'    
    '/L*v'
    $logs
    'REBOOT=REALLYSUPPRESS'
    )

Try{
    #Seems that if it failed before it cannot rerun because it detects the registry key for the current version
    If ($classesreglocation + "\" + $CurrentFaultyInstall){
        Remove-Item ($classesreglocation + "\" + $CurrentFaultyInstall) -Recurse -Force -ErrorAction SilentlyContinue
    }

    #Try install, if fail clean up registry of older version 
    Stop-Process -Name "msi*" -Force -ErrorAction SilentlyContinue
    $Install = Start-Process "msiexec.exe" -ArgumentList $MSIArguments -Wait -NoNewWindow -ErrorAction Stop -PassThru
    
    if ($Install.ExitCode -ne 0){
        Write-Host "Install failed"
        Exit Try
    }
}

Catch{
    #Clean up both HKLM are of the uninstall portion of the registry
    foreach($location in $uninstreglocations)
    {
        foreach($application in $applicationlist)
        {
            $results += (Get-ChildItem -Path $location | Get-ItemProperty | Where-Object {$_.DisplayName -like $application} | Select-Object -Property DisplayName,PSChildName)
        }
    }
    
    foreach($UnInstRegRemoval in $results)
        {
            $UninstCleanup = Join-path $uninstreglocations $UnInstRegRemoval.PSChildName
            Remove-Item $UninstCleanup -Recurse -Force -ErrorAction SilentlyContinue
        }

    #Clean up HKCR area of the installs
    foreach($location in $classesreglocation)
        {
            foreach($application in $applicationlist)
            {
                $results += (Get-ChildItem -Path $location | Get-ItemProperty | Where-Object {$_.ProductName -like $application} | Select-Object -Property ProductName,PSChildName)
            }
        }
    
    foreach($ClassesRegRemoval in $Results)
        {
            $ClassesCleanup = Join-path $classesreglocation $ClassesRegRemoval.PSChildName
            Remove-Item $ClassesCleanup -Recurse -Force -ErrorAction SilentlyContinue
                    
        }

        #Try the install again
        $Install = Start-Process "msiexec.exe" -ArgumentList "$MSIArguments"  -Wait -NoNewWindow -ErrorAction Stop -PassThru

        Return $install.ExitCode
}

      