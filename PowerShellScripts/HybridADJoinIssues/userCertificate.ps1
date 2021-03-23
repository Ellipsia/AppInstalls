#having issues getting systems to AAD Hybrid Join.  Found nuking out userCertificate fixed the issue.

Import-Csv -Path C:\Temp\Azure.csv | ForEach-Object {
    Get-ADComputer $_.DeviceName -Verbose -Properties userCertificate | Set-ADComputer -Clear userCertificate -Verbose
}