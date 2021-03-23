Import-Module ActiveDirectory
$CSV= "C:\Temp\NewPCList.csv"
$OU= "OU=InsertOUStructure,DC=YourDC"
Import-Csv -Path $CSV | ForEach-Object { New-ADComputer -Name $_.ComputerAccount -Path $OU -Enabled $False -Description "Insert Description" -SAMAccountName $_.CompuerAccount}