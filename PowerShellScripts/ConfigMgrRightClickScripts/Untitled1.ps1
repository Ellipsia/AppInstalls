$ProgUninst = Get-WmiObject -Class win32_product | where-object {$_.Name -like "*Java*"}
foreach ($APP in $ProgUninst) {$APP.Uninstall() | out-file $env:windir\Temp\Java.log -append}