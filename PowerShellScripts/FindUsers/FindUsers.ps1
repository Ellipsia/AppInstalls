# Find Current directory
$ScriptPath = $MyInvocation.MyCommand.Path
$CurrentDir = Split-Path $ScriptPath

$ClientList = Get-Content $CurrentDir\FindUsers.csv
$Username = Read-Host -Prompt "Which username do you want me to find?"

$ClientList | ForEach-Object {
    Write-Host $_
    # Find current system path
    $Path = '\\' + $_ + '\C$\Users\' + $Username
    
    If (Test-Path -Path $Path -PathType Container) {
    
    # Write which PC's it was found on.
    Write-Host $_ ' - folder found in users directory'
      
    }

} 