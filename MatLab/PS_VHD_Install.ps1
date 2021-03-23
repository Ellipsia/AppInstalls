#Thanks to @jgkps for the installation method and @LtBehr for his version of the PS Script, which this is based upon.

#Folder containing this script. VHD should reside in the root alongside the script.
if(!$PSScriptRoot){$PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent}

#VHD Path
$vhd = (Get-ChildItem $PSScriptRoot\*.vhd)

Try{
#Mount VHD and get its Drive Letter for use in the installation command.
#Drive will be writeable by default to allow for installers that write temp files. Add -ReadOnly to Mount-DiskImage if this is not desired.
$Volume_Letter = (Mount-DiskImage $vhd -PassThru | Get-DiskImage | Get-Disk | Get-Partition | Get-Volume).DriveLetter
}Catch{
Exit 1
}

Try{
#Execute your silent install command here. 
    
    [string]$appVersion = 'R2020a'
    [string]$installDirectory = "C:\Program Files\MATLAB\$appVersion\"
    #[string]$matLabUpdate = "R2018a_Update_5.exe"
    
    ## Uninstall old versions
    $MATLABInstalls = Get-ChildItem -Path $env:ProgramFiles\MATLAB | Select FullName
    
    ForEach ($MATLABVer in $MATLABInstalls.FullName) {
        If (Test-Path "$MATLABVer\Uninstall\Bin\win64\uninstall.exe"){
            Start-Process -FilePath "$MATLABVer\uninstall\bin\win64\uninstall.exe" -ArgumentList "-inputFile `"$PSScriptRoot\uninstaller_input.txt`"" -Wait
        }
    }

    ## Clean up bunk installation        
    If (Test-Path -LiteralPath $installDirectory) {
        Remove-Item $installDirectory -Recurse -Force
    }
      
    ## Make new MATLAB folder for license file
    New-Item -ItemType Directory -Path $installDirectory -Force
    Copy-Item -Path "$($Volume_Letter):\license.dat" -Destination $installDirectory

    ##Install MATLAB
    Start-Process "$($Volume_Letter):\Setup.exe" -ArgumentList "-inputfile $($Volume_Letter):\installer_input.txt" -Wait

    ##Install Update
    #Start-Process "$($Volume_Letter):\$matLabUpdate" -ArgumentList "/S /D=$installDirectory" -Wait

    # Set file associations
    Start-Process -Path "$installDirectory\bin\win64\fileassoc.exe" -ArgumentList "--mlroot `"$installDirectory`" --products 4 --install"
    
}Catch{
#Unmount the VHD if we fail.
Dismount-DiskImage $vhd
}

Try{
#Unount the VHD when we are done.
Dismount-DiskImage $vhd
}Catch{
Exit 1
}