<#
.Synopsis
	Sets or removes environment variables (Windows User/Machine).
	Author: Roman Kuzmin

.Description
	This command sets or removes the current User or local Machine environment
	variable and updates the current process environment variable accordingly.

.Link
	Set-Env.ArgumentCompleters.ps1

.Parameter Name
		Specifies the environment variable name.

.Parameter Value
		Specifies the environment variable value.
		If it is omitted or empty then the variable is removed.

.Parameter Machine
		Tells to update the local Machine variable.
		By default it updates the current User variable.

.Link
	https://github.com/nightroman/PowerShelf
#>

[CmdletBinding()]
param(
	[Parameter(Mandatory=1)]
	[string]$Name,
	[string]$Value,
	[switch]$Machine
)

$ErrorActionPreference = 'Stop'
$target = if ($Machine) {'Machine'} else {'User'}

# set registry variable
[System.Environment]::SetEnvironmentVariable($Name, $Value, $target)

# special cases
if ($target -eq 'Machine') {
	$value2 = [System.Environment]::GetEnvironmentVariable($Name, 'User')
	if ($value2) {
		Write-Warning "Set-Env: Existing User variable '$Name' takes over."
		$Value = $value2
	}
}
elseif ($target -eq 'User' -and !$Value) {
	$value2 = [System.Environment]::GetEnvironmentVariable($Name, 'Machine')
	if ($value2) {
		Write-Warning "Set-Env: Existing Machine variable '$Name' takes over."
		$Value = $value2
	}
}

# set process variable
[System.Environment]::SetEnvironmentVariable($Name, $Value, 'Process')
