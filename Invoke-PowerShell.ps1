<#PSScriptInfo
.VERSION 1.0.5
.AUTHOR Roman Kuzmin
.COPYRIGHT (c) Roman Kuzmin
.TAGS Test
.GUID 77483ce2-8c29-495b-9cca-cf079804f832
.PROJECTURI https://github.com/nightroman/PowerShelf
.LICENSEURI http://www.apache.org/licenses/LICENSE-2.0
#>

<#
.Synopsis
	Invokes new PowerShell of the currently running version.

.Description
	This script invokes powershell/pwsh of the same version as the current:
	- Windows PowerShell -Version 2
	- Windows PowerShell v3+
	- PowerShell Core v6+

	Arguments of the script are passed in powershell/pwsh.

.Link
	https://github.com/nightroman/PowerShelf
#>

trap {Write-Error -ErrorRecord $_}

if ($PSVersionTable.PSVersion.Major -eq 2) {
	powershell.exe -Version 2 @args
}
elseif ($PSVersionTable.PSVersion.Major -le 5) {
	powershell.exe @args
}
else {
	$exe = [System.Diagnostics.Process]::GetCurrentProcess().Path
	if ([System.IO.Path]::GetFileNameWithoutExtension($exe) -eq 'pwsh') {
		& $exe @args
	}
	else {
		pwsh @args
	}
}
