#Scripts taken from SirWarlord on WinAdmins Discord Chat

$applicationlist =@("Java 8 Update *")
$results = @()
$reglocations = @("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall","HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall")

foreach($location in $reglocations)
    {
        foreach($application in $applicationlist)
        {
            $results += (Get-ChildItem -Path $location | Get-ItemProperty | Where-Object {$_.DisplayName -like $application} | Select-Object -Property DisplayName, PSChildName, Version)
        }
    }
    
foreach($UnInstall in $results)
    {
                
        $MSIArguments = @(
        '/x'
        $UnInstall.PSChildName
        '/qn'    
        '/L*v "C:\Windows\Temp\' + $($UnInstall.DisplayName)+'.log"'
        'REBOOT=REALLYSUPPRESS'
        )
               
        $Uninstaller = Start-Process "msiexec.exe" -ArgumentList $MSIArguments -Wait -NoNewWindow -ErrorAction Stop -PassThru
                    
    }