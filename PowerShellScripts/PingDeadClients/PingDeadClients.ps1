# Name the file DeadClients.csv
# Used this for finding objects when we first got ConfigMgr and it would see online systems that were not talking to ConfigMgr but were in fact online

# Find Current directory
$ScriptPath = $MyInvocation.MyCommand.Path
$CurrentDir = Split-Path $ScriptPath

# Import in list of dead clients
$ClientList = Get-Content $CurrentDir\DeadClients.csv


$ClientList | ForEach-Object {

    $Path = '\\' + $_ + '\C$'
    If (Test-Path -Path $Path -PathType Container) {
        New-Object -TypeName PSCustomObject -Property @{
        VMName = $_
        'UNC Path' = 'Ok'
        }
    } else {
        New-Object -TypeName PSCustomObject -Property @{
        VMName = $_
        'UNC Path' = 'Failed'
        }
    }

} | Export-Csv -Path $CurrentDir\DeadClients-Results.csv -NoTypeInformation