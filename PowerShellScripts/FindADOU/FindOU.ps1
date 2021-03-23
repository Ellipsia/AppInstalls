# Find Current directory
$ScriptPath = $MyInvocation.MyCommand.Path
$CurrentDir = Split-Path $ScriptPath

# Bring in system list
$ClientList = Get-Content $CurrentDir\NoLabels.csv

# Process each system and find it's AD OU
$ClientList | ForEach-Object {    
    
    $ADDisName = Get-ADComputer -Identity $_ | Select -expand DistinguishedName

    If ($ADDisName) {
        New-Object -TypeName PSCustomObject -Property @{
        SystemName = $_
        'AD DN' = $ADDisName
        }
    } else {
        New-Object -TypeName PSCustomObject -Property @{
        SystemName = $_
        'AD DN' = 'Not in AD'
        }
        write-host $ADDisName
    }

    # Clear variable
    $ADDisName = ''

    # Export all data to a CSV
} | Export-Csv -Path $CurrentDir\ADOU-Results.csv -NoTypeInformation