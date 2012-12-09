
<#
.Synopsis
	Invokes a command and imports its environment variables.
	Author: Roman Kuzmin (inspired by Lee Holmes's Invoke-CmdScript.ps1)

.Description
	It invokes the specified command (normally a configuration batch file) and
	imports its environment variables to the current PowerShell environment.

.Parameter Command
		Specifies a command being invoked, e.g. a configuration batch file.
		This string is the whole command text passed in cmd /c. Do not use
		redirection operators in it, they are used by the script. Output is
		discarded by default. Use the switch Output in order to receive it.
.Parameter Output
		Tells to collect and return the command output.
.Parameter Force
		Tells to import variables even if the command exit code is not 0.

.Inputs
	None. Use the script parameters.
.Outputs
	None or the command output.

.Example
	>
	# Invoke vsvars32 and import its environment even if exit code is not 0
	Invoke-Environment '"%VS100COMNTOOLS%\vsvars32.bat"' -Force

	# Invoke Config.bat and show its output
	Invoke-Environment Config.bat -Output

.Link
	https://github.com/nightroman/PowerShelf
#>

param
(
	[Parameter(Mandatory=1)][string]$Command,
	[switch]$Output,
	[switch]$Force
)

$stream = if ($Output) { ($temp = [IO.Path]::GetTempFileName()) } else { 'nul' }
$operator = if ($Force) {'&'} else {'&&'}

foreach($_ in cmd /c "$Command > `"$stream`" 2>&1 $operator set") {
	if ($_ -match '^([^=]+)=(.*)') {
		[System.Environment]::SetEnvironmentVariable($matches[1], $matches[2])
	}
}

if ($Output) {
	Get-Content -LiteralPath $temp
	Remove-Item -LiteralPath $temp
}
