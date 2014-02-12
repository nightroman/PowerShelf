
<#
.Synopsis
	Enables debugging on terminating errors.
	Author: Roman Kuzmin

.Description
	The command exploits updates of the variable StackTrace on terminating
	errors. Setting this variable breakpoint enables debugging on failures.

	Without parameters this command enables debugging on failures globally.
	Invoke a troublesome script and debug it right at the problem point.

	Use the switch Off in order to turn debugging on errors off.

.Parameter Script
		Sets a breakpoint in each of the specified script files.
		See: Get-Help Set-PSBreakpoint -Parameter Script
.Parameter Action
		Specifies commands that run at each breakpoint.
		See: Get-Help Set-PSBreakpoint -Parameter Action
.Parameter Off
		Tells to turn debugging on errors off, i.e. remove all StackTrace
		breakpoints. Other parameters are ignored.

.Inputs
	None
.Outputs
	None

.Link
	https://github.com/nightroman/PowerShelf
#>

param(
	[Parameter()]
	[string[]]$Script,
	[scriptblock]$Action,
	[switch]$Off
)

Get-PSBreakpoint -Variable StackTrace | Remove-PSBreakpoint

if (!$Off) {
	if ($Script) {
		$null = Set-PSBreakpoint -Variable StackTrace -Mode Write -Action $Action -Script $Script
	}
	else {
		$null = Set-PSBreakpoint -Variable StackTrace -Mode Write -Action $Action
	}
}
