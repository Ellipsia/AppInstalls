Param(
    [Parameter(Mandatory=$True)]
    [string]$ServiceName
)

If (Get-Service -Name $ServiceName) {
    Try {
        Restart-Service -Name $ServiceName -Force -ErrorAction Stop
        Write-Output "Successfully restarted service $ServiceName"
    }
    Catch {
        Write-Output "Failed to restart service $ServiceName"
    }
}
else {
    Write-Output "Failed to locate service $ServiceName"
}