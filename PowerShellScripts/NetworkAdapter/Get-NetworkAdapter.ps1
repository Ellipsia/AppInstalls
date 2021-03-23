<#
.Synopsis
   Scripts searches Win32_NetworkAdapter and finds if it's Ethernet or Wi-Fi
.DESCRIPTION
   
.EXAMPLE

#>

Try {

    If (Get-WmiObject -Class win32_NetworkAdapter -filter "netconnectionstatus = 2" -ErrorAction 'Stop' | Select netconnectionid | Where-Object {$_.netconnectionid -eq 'Ethernet'}) {

        #Return $true
        $LASTEXITCODE = 0
    
    } else {

        #Return $false
        $LASTEXITCODE = 1

    }
} Catch {

   #Return $false
   $LASTEXITCODE = 1

}