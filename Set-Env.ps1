<#
.Synopsis
	Sets or removes environment variables (Windows User/Machine/Process).
	Author: Roman Kuzmin

.Description
	This command sets the current process environment and sets the current User
	or local Machine environment, depending on Target (default: User).

.Link
	Set-Env.ArgumentCompleters.ps1

.Parameter Name
		Specifies the environment variable name.

.Parameter Value
		Specifies the environment variable value.
		If it is omitted or empty then the variable is removed.

.Parameter $Target
		Specifies the environment target.
		User is the default.

.Link
	https://github.com/nightroman/PowerShelf
#>

[CmdletBinding()]
param(
	[Parameter(Mandatory=1)]
	[string]$Name
	,
	[string]$Value
	,
	[ValidateSet('User', 'Machine', 'Process')]
	[string]$Target = 'User'
)

$ErrorActionPreference = 'Stop'
$ValueOrNull = if ($Value) {$Value} else {[NullString]::Value}

# set target variable
[System.Environment]::SetEnvironmentVariable($Name, $ValueOrNull, $Target)

# target cases
if ($Target -eq 'Process') {
	return
}
elseif ($Target -eq 'Machine') {
	$value2 = [System.Environment]::GetEnvironmentVariable($Name, 'User')
	if ($null -ne $value2) {
		Write-Warning "Set-Env: Existing User variable '$Name' takes over."
		$ValueOrNull = $value2
	}
}
elseif ($Target -eq 'User' -and !$Value) {
	$value2 = [System.Environment]::GetEnvironmentVariable($Name, 'Machine')
	if ($null -ne $value2) {
		Write-Warning "Set-Env: Existing Machine variable '$Name' takes over."
		$ValueOrNull = $value2
	}
}

# set process variable
[System.Environment]::SetEnvironmentVariable($Name, $ValueOrNull, 'Process')
