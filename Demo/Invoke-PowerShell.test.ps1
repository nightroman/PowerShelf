
<#
.Synopsis
	Tests Invoke-PowerShell.ps1.
#>

task SameVersion {
	($r = exec {Invoke-PowerShell.ps1 -NoProfile -Command '$PSVersionTable.PSVersion.ToString()'})
	equals $r ($PSVersionTable.PSVersion.ToString())
}
