# MatLab

MatLab VHD and PowerShell Installer

Prepping the VHD
1. Get license key string to add to the installer_input.txt from previous years package.
	a. fileInstallationKey=<Key from software services>
2. Usually take old installer_input.txt and just modify it to current version with key, log path, and licensepath.  If this is not possible, the follow changes are made 	to the file:
	a. destinationFolder=C:\Program Files\MATLAB\<Version>
	b. fileInstallationKey=<Key from software services>
	c. agreeToLicense=yes
	d. outputFile=C:\Windows\Temp\MATLAB-<version>.log
	e. mode=silent
	f. licensePath=C:\Program Files\MATLAB\<version>\license.dat
	g. lmgrFiles=false
	h. lmgrService=false
	i. desktopShortcut=false
	j. startMenuShortcut=true
	k. createAccelTask=false
	l. enableLNU=no
3. Copy old uninstaller_input.txt from previous year and put it in the root folder, if not, add following lines:
	a. outputFile=C:\Windows\Temp\MATLAB_Uninstall.log
	b. mode=silent
	c. prefs=True
4. Copy license.dat to main directory
5. After this, create the below VHD

Using a new methodology to install this application.

https://github.com/winadminsdotorg/SystemCenterConfigMgr/tree/master/Applications/Scripts/VHD_Application_Install

	1. Create a VHD using above method
	2. Used Dynamic Disk instead of Fixed, I did this so we could minimize the size of the VHD and let it auto expand.
	3. Use script and modify for the current version or if there is an update or not.
	4. #Thanks to @jgkps for the installation method and @LtBehr for his version of the PS Script, which this is based upon.
	
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
	    
	    [string]$appVersion = 'R2018a'
	    [string]$installDirectory = "C:\Program Files\MATLAB\$appVersion\"
	    [string]$matLabUpdate = "R2018a_Update_5.exe"
	
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
	    Copy-Item -Path "$($Volume_Letter):\license.dat" -Destination $installDirectory -Verbose
	
	    ##Install MATLAB
	    Start-Process "$($Volume_Letter):\Setup.exe" -ArgumentList "-inputfile $($Volume_Letter):\installer_input.txt" -Wait
	
	    ##Install Update
	    Start-Process "$($Volume_Letter):\$matLabUpdate" -ArgumentList "/S /D=$installDirectory" -Wait
	
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

NOTE: When creating a deployment type, be sure to set run as 32bit on a 64bit machine. See below screenshot.  It seems to run out of memory and give java errors if you don't.  I still need to finish up a good powershell uninstall script to remove all versions dynamically.
