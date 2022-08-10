<#
.Synopsis
	Tests PowerShell debugging with breakpoints.
	Author: Roman Kuzmin

.Description
	This scripts helps to get familiar with various breakpoints: command,
	variable (reading, writing, reading and writing), and custom actions.
	It is also useful for testing debuggers, e.g. Add-Debugger.ps1.

	The script sets some breakpoints in itself and triggers them all during
	execution. In order to set breakpoints without testing, use NoTest. In
	order to remove breakpoints, use RemoveBreakpoints.

	With built-in debuggers it is ready to use, e.g. with
	- ConsoleHost
	- VSCode PowerShell host
	- Windows PowerShell ISE Host
	- FarHost (in the main session)

	Use it with a custom debugger, e.g. Add-Debugger.ps1, with
	- Default Host (simple calls of PowerShell from .NET)
	- Package Manager Host (Visual Studio NuGet console)
	- FarHost

.Parameter NoTest
		Tells to set breakpoints and exit without testing.

.Parameter RemoveBreakpoints
		Tells to remove breakpoints set for this script.

.Example
	>
	# add debugger (or use the built-in and skip this)
	Add-Debugger.ps1

	# set and test breakpoints
	Test-Debugger.ps1

.Link
	https://github.com/nightroman/PowerShelf
#>

[CmdletBinding()]
param(
	[switch]$NoTest
	,
	[switch]$RemoveBreakpoints
)

# this script path
$script = $MyInvocation.MyCommand.Definition

# get its breakpoints
$breakpoints = Get-PSBreakpoint | Where-Object { $_.Script -eq $script }

### remove breakpoints and exit
if ($RemoveBreakpoints) {
	$breakpoints | Remove-PSBreakpoint
	return "Removed $($breakpoints.Count) breakpoints."
}

### set breakpoints and exit
if (!$breakpoints) {
	# command breakpoint, e.g. function TestFunction1
	$null = Set-PSBreakpoint -Script $script -Command TestFunction1

	# variable breakpoint on reading
	$null = Set-PSBreakpoint -Script $script -Variable varRead -Mode Read

	# variable breakpoint on writing
	$null = Set-PSBreakpoint -Script $script -Variable varWrite -Mode Write

	# variable breakpoint on reading and writing
	$null = Set-PSBreakpoint -Script $script -Variable varReadWrite -Mode ReadWrite

	# special handy breakpoint enables debugging of terminating errors
	$null = Set-PSBreakpoint -Script $script -Variable StackTrace -Mode Write

	# special breakpoint with action without breaking (for logging, diagnostics and etc.)
	# NOTE: mind infinite recursion (stack overflow) if the action accesses the same variables
	$null = Set-PSBreakpoint -Script $script -Variable 'varRead', 'varWrite', 'varReadWrite' -Mode ReadWrite -Action {
		++$script:VarAccessCount
	}

	if ($NoTest) {
		return 'Breakpoints are set, invoke the script again to test.'
	}
}

### proceed with the breakpoints

# it is updated by the breakpoint action
$script:VarAccessCount = 0

# a command breakpoint is set for this function
function TestFunction1 {
	TestFunction2 42 text @{data=3.14} # try to step into, over, out
	'In TestFunction1'
}

# function to test stepping into from TestFunction1
function TestFunction2 { # you have stepped into TestFunction2
	param($int, $text, $data)
	'In TestFunction2'
}

# test a command breakpoint
TestFunction1 # in v2 it stops here, in v3 in the function

# non terminating error does not trigger debugging
Write-Error 'This is non terminating demo error.' -ErrorAction SilentlyContinue

# terminating error triggers the StackTrace breakpoint
try { Write-Error 'This is terminating demo error.' -ErrorAction Stop }
catch { $_ }

# to change the variable in a debugger, mind that in some debuggers it is the
# current scope, in others it may be the parent scope (Add-Debugger.ps1).
[int]$toWrite = 0 # change me after
if ($toWrite -le 0) {
	"Nothing to write."
}
else {
	"Writing..."
	1..$toWrite
}

# steps in one line
if ($true) { $_ = 1 } # step through the pieces of command

$varRead = 1 # no break
$_ = $varRead # break on reading

$varWrite = 2 # break on writing
$_ = $varWrite # no break

$varReadWrite = 3 # break on writing
$_ = $varReadWrite # break on reading

# it was updated by the breakpoint action
"Watched variables have been accessed $($script:VarAccessCount) times."
