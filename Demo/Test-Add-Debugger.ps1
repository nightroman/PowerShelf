
<#
.Synopsis
	Tests Add-Debugger.ps1.

.Description
	Requires Add-Debugger.ps1 and Test-Debugger.ps1 in the path. This test is
	automated, it simulates debugger input by the fake function. Output is
	written to the file (with a weird name, to be sure it's supported).
#>

# remove log
$log = "$env:TEMP\]'``debug``'[.log"
if (Test-Path -LiteralPath $log) { Remove-Item -LiteralPath $log }

# make a mini script module to be tested as well
@'
# test module
function TestModule1 {
	'In TestModule1'
}
'@ > $env:TEMP\debug.psm1

# add debugger
Add-Debugger.ps1 $log
if (!(Test-Path Variable:\_Debugger)) {throw}

# steps
$global:step = 0
$global:steps = @(
	@{
		read = '?'
		test = { if ($nWatchDebugger -ne 1) {throw} }
	}
	@{
		read = '3'
		test = { if ($nWatchDebugger -ne 1) {throw} }
	}
	's'
	'+3'
	's'
	's'
	'k'
	'K'
	'k 1'
	'k 1 3'
	'k 3'
	'k 4'
	'k 5'
	'o'
	'c'
	'gl'
	'1 + 1'
	'missing'
	'gl'
	'r'
	'v'
	'c'
	'c'
	'c'
	'c'
	'c'
	'q'
)

# fake
$global:nWatchDebugger = 0
function Watch-Debugger {
	++$global:nWatchDebugger
}

# fake
function Read-Debugger
{
	if ($global:step -ge $steps.Count) {throw}
	$data = $steps[$step]
	++$global:step

	if ($data -is [string]) {
		return $data
	}

	& $data.test
	$data.read
}

# test breakpoints
Test-Debugger.ps1 # set
Test-Debugger.ps1 # run

# test a script module breakpoint
$null = Set-PSBreakpoint -Command TestModule1
Import-Module $env:TEMP\debug.psm1
TestModule1
