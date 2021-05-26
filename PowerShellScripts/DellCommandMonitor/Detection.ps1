<#
.Synopsis
    Detects broken DCM installs
.DESCRIPTION
    Searches WMI to verify it is intact due to build upgrades or new features in DCIM.  If not, remediate.
.EXAMPLE
   
#>

#Variables to test WMI and DCIM
$BIOSElementTest = Get-WmiObject -Namespace 'Root\DCIM\SYSMAN' -Class 'DCIM_BIOSElement' -ErrorAction SilentlyContinue
$WarrantyInfoTest = Get-WmiObject -Namespace 'Root\DCIM\SYSMAN' -Class 'DCIM_AssetWarrantyInformation' -ErrorAction SilentlyContinue | Select Name

# Check WMI to see if was a build upgrade and lost DCIM
if ($BIOSElementTest -and ($WarrantyInfoTest.Name -ne 'Please set the value')){
    Write-Output "Compliant"
    Exit 0   
}
elseif (($BIOSElementTest -eq $null) -and ($WarrantyInfoTest -eq $null)){
    Write-Output "Compliant"
    Exit 0   
}
else{
    Write-Output "Not Compliant"
    Exit 1
}