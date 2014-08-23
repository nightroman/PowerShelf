
<#
.Synopsis
	Provides script tracing and coverage data collection.
	Author: Roman Kuzmin

.Description
	This script is designed as the alternative to "Set-PSDebug -Trace".
	It avoids some known Set-PSDebug issues and provides extra features.

	The script is useful for troubleshooting in the first place. Its second
	goal is generating data on testing for further script coverage analysis.

	The built-in PowerShell debugger is replaced by the debugger which performs
	tracing. In order to restore the original debugger and stop tracing invoke
	Restore-Debugger. This command also removes temporary breakpoints and
	closes the output file if it is used.

.Parameter Command
		Specifies the commands which trigger tracing, often a script being
		traced. In fact, any breakpoint which is hit triggers tracing. The
		parameter just helps to set some breakpoints. Such breakpoints are
		removed automatically by Restore-Debugger.

.Parameter Filter
		Specifies the filter scriptblock which tests the variable $ScriptName
		and returns $true in order to trace or $false in order to ignore.
		$ScriptName contains the full path of a script being invoked.

		The code must not change anything in the session, this may break normal
		program flow. For example, the operator -match must not be used because
		it changes the automatic variable $Matches and other code with $Matches
		may work incorrectly on tracing.

.Parameter Path
		Specifies the file used instead of the default Write-Host output. The
		data are appended to this file. Thus, the same file may be used many
		times, e.g. on collecting code coverage data by several tests.

		The file remains opened until Restore-Debugger is called or PowerShell
		exits. Note that tracing may produce very large output. If this is a
		problem then try to use Filter to reduce output or Table to collect
		relatively compact coverage data.

.Parameter Table
		Tells to collect script coverage data and specifies the variable name.
		The variable is a hashtable created in the global scope. The keys are
		script paths, values are hashtables where keys are line numbers and
		values are line pass counters.

		Coverage data can be shown as HTML by the script Show-Coverage.ps1.

.Inputs
	None
.Outputs
	None

.Example
	>
	How to trace Test-Debugger.ps1. Test-Debugger is invoked twice. The first
	call simply sets breakpoints. The second call does actual work, not much.
	Note that breakpoints are not triggered in a usual way on tracing because
	the original debugger is replaced by the temporary tracing debugger. But
	action script blocks specified for some breakpoints are still invoked.

	# enable tracing with the trigger command
	Trace-Debugger Test-Debugger

	# invoke with tracing
	Test-Debugger
	Test-Debugger

	# stop tracing
	Restore-Debugger

.Example
	>
	How to collect and show script coverage data

	# enable tracing with result data table
	Trace-Debugger Test.ps1 -Table Coverage

	# invoke with tracing
	Test.ps1

	# stop tracing
	Restore-Debugger

	# show coverage data
	Show-Coverage $Coverage

.Link
	https://github.com/nightroman/PowerShelf
.Link
	Show-Coverage.ps1
#>

[CmdletBinding(DefaultParameterSetName='All')]
param(
	[Parameter(Position=0)]
	[string[]]$Command,
	[Parameter(Position=1)]
	[scriptblock]$Filter,
	[Parameter(ParameterSetName='Path', Mandatory=1)]
	[string]$Path,
	[Parameter(ParameterSetName='Table', Mandatory=1)]
	[string]$Table
)

# Restore another debugger by its Restore-Debugger.
if (Test-Path Variable:\_Debugger) {
	Restore-Debugger
}

# Removes and gets debugger handlers.
function global:Remove-Debugger {
	$instance = [System.Management.Automation.Runspaces.Runspace]::DefaultRunspace.Debugger
	$type = [System.Management.Automation.Debugger]
	$e = $type.GetEvent('DebuggerStop')
	$v = $type.GetField('DebuggerStop', ([System.Reflection.BindingFlags]'NonPublic, Instance')).GetValue($instance)
	if ($v) {
		$handlers = $v.GetInvocationList()
		foreach($handler in $handlers) {
			$e.RemoveEventHandler($instance, $handler)
		}
		$handlers
	}
}

# Restores original debugger handlers.
function global:Restore-Debugger {
	if (!(Test-Path Variable:\_Debugger)) {return}
	$null = Remove-Debugger
	if ($_Debugger.Handlers) {
		foreach($handler in $_Debugger.Handlers) {
			[System.Management.Automation.Runspaces.Runspace]::DefaultRunspace.Debugger.add_DebuggerStop($handler)
		}
	}

	if ($_Debugger.Writer) {$_Debugger.Writer.Close()}
	$_Debugger.Breakpoints | Remove-PSBreakpoint

	Remove-Variable _Debugger -Scope Global -Force
}

### Debugger data
$null = New-Variable -Name _Debugger -Scope Global -Description Trace-Debugger.ps1 -Option ReadOnly -Value @{
	Breakpoints = @(
		if ($Command) {Set-PSBreakpoint -Command $Command}
		Set-PSBreakpoint -Command Restore-Debugger -Action {$_Debugger.Filter = {0}}
	)
	Handlers = Remove-Debugger
	Filter = $Filter
}

### Table
if ($PSCmdlet.ParameterSetName -eq 'Table') {
	$_Debugger.Table = @{}
	$null = New-Variable -Name $Table -Scope Global -Value $_Debugger.Table -Force
}
else {
	$_Debugger.Table = $null
}

### Path
if ($PSCmdlet.ParameterSetName -eq 'Path') {
	$writer = New-Object System.IO.StreamWriter ($PSCmdlet.GetUnresolvedProviderPathFromPSPath($Path)), $true
	$writer.AutoFlush = $true
	$_Debugger.Writer = $writer
	function global:Write-Debugger($Data)
	{
		$_Debugger.Writer.WriteLine($Data)
	}
}
elseif ($Host.Name -eq 'ConsoleHost') {
	$_Debugger.Writer = $null
	function global:Write-Debugger($Data)
	{
		Write-Host $Data -ForegroundColor $Host.PrivateData.DebugForegroundColor
	}
}
else {
	$_Debugger.Writer = $null
	function global:Write-Debugger($Data)
	{
		Write-Host $Data
	}
}

# Add tracing debugger.
[System.Management.Automation.Runspaces.Runspace]::DefaultRunspace.Debugger.add_DebuggerStop({. Invoke-DebuggerStop})

# Processes DebuggerStop events.
function global:Invoke-DebuggerStop
{
	$_.ResumeAction = 'StepInto'
	$InvocationInfo = $_.InvocationInfo

	$ScriptName = $InvocationInfo.ScriptName
	if ($_Debugger.Filter -and !(& $_Debugger.Filter)) {return}

	if ($ScriptName) {
		if ($data = $_Debugger.Table) {
			$file = $data[$ScriptName]
			if (!$file) {
				$data.Add($ScriptName, ($file = @{}))
			}
			++$file[$InvocationInfo.ScriptLineNumber]
		}
		else {
			Write-Debugger @"
$($ScriptName)($($InvocationInfo.ScriptLineNumber),$($InvocationInfo.OffsetInLine))
+ $(($InvocationInfo.Line.Substring(0, $InvocationInfo.OffsetInLine - 1) + ' >>>> ' + $InvocationInfo.Line.Substring($InvocationInfo.OffsetInLine - 1)).Trim())
"@
		}
	}
	elseif (!$_Debugger.Table) {
		Write-Debugger $InvocationInfo.PositionMessage
	}
}
