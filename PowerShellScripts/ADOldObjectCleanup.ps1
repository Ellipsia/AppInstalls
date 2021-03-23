$datecutoff = (Get-Date).AddDays(-182)
$fileexport = "C:\temp\ComputerLastLogonDate-0.5Year.csv"

Get-ADComputer -SearchBase 'OU=Yourplace,DC=YourDC' -Filter {LastLogonDate -lt $datecutoff} -Properties Name, LastLogonDate, OperatingSystem | Select Name, LastLogonDate, OperatingSystem | Export-CSV $fileexport