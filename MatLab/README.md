# MatLab

MatLab VHD and PowerShell Installer

Prepping the VHD
1. Get license key string to add to the installer_input.txt from previous years package.
	1. fileInstallationKey=<Key from software services>
2. Usually take old installer_input.txt and just modify it to current version with key, log path, and licensepath.  If this is not possible, the follow changes are made to the file:
	1. destinationFolder=C:\Program Files\MATLAB\<Version>
	2. fileInstallationKey=<Key from software services>
	3. agreeToLicense=yes
	4. outputFile=C:\Windows\Temp\MATLAB-<version>.log
	5. mode=silent
	6. licensePath=C:\Program Files\MATLAB\<version>\license.dat
	7. lmgrFiles=false
	8. lmgrService=false
	9. desktopShortcut=false
	10. startMenuShortcut=true
	11. createAccelTask=false
	12. enableLNU=no
3. Copy old uninstaller_input.txt from previous year and put it in the root folder, if not, add following lines:
	1. outputFile=C:\Windows\Temp\MATLAB_Uninstall.log
	2. mode=silent
	3. prefs=True
4. Copy license.dat to main directory
5. After this, create the below VHD

Using a new methodology to install this application.

https://github.com/winadminsdotorg/SystemCenterConfigMgr/tree/master/Applications/Scripts/VHD_Application_Install

	1. Create a VHD using above method
	2. Used Dynamic Disk instead of Fixed, I did this so we could minimize the size of the VHD and let it auto expand.
	3. Use the script I've attached in the folder attached and modify for the current version or if there is an update or not.
	4. NOTE: When creating a deployment type, be sure to set run as 32bit on a 64bit machine. It seems to run out of memory and give java errors if 		you 		don't.  I still need to finish up a good powershell uninstall script to remove all versions dynamically.
