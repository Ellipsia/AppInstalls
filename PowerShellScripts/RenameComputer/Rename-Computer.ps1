# Script to rename computers in a domain by parsing a CSV file 
# Assumes: File of names with a header row of OldName,NewName
# and a row for oldname,newname pairs for each computer to be renamed.
# Adjust filename and file path as appropriate. 

$ScriptPath = $MyInvocation.MyCommand.Path
$CurrentDir = Split-Path $ScriptPath
  
$csvfile = "$currentdir\Rename-Computer.csv"

# Prompt for user credentials securely
$domainUser = Read-Host "Enter username (blah@somewhere.com)"
$domainPass = Read-Host "Enter password"

# Read CSV and pass new computer names
Import-Csv $csvfile | foreach { 
    $oldName = $_.OldName;
    $newName = $_.NewName;
  
    Write-Host "Renaming computer from: $oldName to: $newName"
    netdom renamecomputer $oldName /newName:$newName /uD:$domainUser /passwordD:$domainPass /force /reboot
}