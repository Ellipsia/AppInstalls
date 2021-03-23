$missing = "0"
$RSAT = Get-WindowsCapability -Name RSAT* -Online
foreach ($r in $RSAT) {
    if ($r.State -eq "NotPresent") {
        $missing = 1
    }
}
if ($missing -eq 0) {
write-host = "RSAT Features Detected"
}