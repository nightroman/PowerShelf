
<#PSScriptInfo
.VERSION 1.0.0
.AUTHOR Roman Kuzmin
.COPYRIGHT (c) Roman Kuzmin
.TAGS Test
.GUID 77483ce2-8c29-495b-9cca-cf079804f832
.LICENSEURI http://www.apache.org/licenses/LICENSE-2.0
.PROJECTURI https://github.com/nightroman/PowerShelf
#>

<#
.Synopsis
	Invokes PowerShell of the currently running version.

.Description
	This script invokes powershell.exe of the same version as the current:
	- Windows PowerShell -Version 2
	- Windows PowerShell v3+
	- PowerShell Core v6

	Arguments of the script are passed in powershell.exe

.Link
	https://github.com/nightroman/PowerShelf
#>

if ($PSVersionTable.PSVersion.Major -eq 2) {
	powershell.exe -Version 2 @args
}
else {
	& ((Get-Process -Id $PID).Path) @args
}
