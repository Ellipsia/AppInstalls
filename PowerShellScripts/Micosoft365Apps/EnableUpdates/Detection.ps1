#Detects systems with Office updates disabled
#
#

$64bitPath = "HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration"
$32bitPath = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Office\ClickToRun\Configuration"
$Name = "UpdatesEnabled"
$Value = $false
$Registry32bit = $null
$Registry64bit = $null
 
Try {
    $Registry32bit = Get-ItemProperty -Path $32bitPath -Name $Name -ErrorAction SilentlyContinue
    $Registry64bit = Get-ItemProperty -Path $64bitPath -Name $Name -ErrorAction SilentlyContinue
    
    If ($Registry32bit -eq $Value) {
        Write-Output "Compliant"
        Exit 0
    }
    If ($Registry64bit -eq $Value) {
        Write-Output "Compliant"
        Exit 0
    }
    If (($Registry32bit -eq $null) -and ($Registry64bit -eq $null))
    {
        Write-Output "Compliant"
        Exit 0
    }

    Write-Warning "Not Compliant"
    Exit 1
}
Catch {
    Write-Warning "Not Compliant"
    Exit 1
}