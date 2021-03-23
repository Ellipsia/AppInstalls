<#
.Synopsis
   This PowerShell script removes whatever product is listed in parameters
.DESCRIPTION
   Test doing the Get-WmiObject for what name you are looking for in WMI.
   Example, Get-WmiObject -Class win32_product | where-object {$_.Name -like "*Google Chrome*"}.  
.EXAMPLE
   .\Unisntall.ps1.  
   If using in SCCM for the uninstall portion
   powershell.exe -nologo -executionpolicy bypass -WindowStyle hidden -noprofile -file "Uninstall.ps1"
#>


[cmdletbinding()]
Param (
    $Product = 'Google Chrome'
    )

Try
{
    $ProgUninst = Get-WmiObject -Class win32_product | where-object {$_.Name -like "*$Product*"}
    foreach ($APP in $ProgUninst) {
        $APP.Uninstall() | out-file $env:windir\Temp\"$Product".log -append
    }
}
Catch
{
   $Time = Get-Date
   "Uninstall of $Product failed at $Time" | out-file $env:windir\Temp\"$Product"UninstallFailed.log -append
}