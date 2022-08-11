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

# fake
$global:nWatchDebugger = 0
function Watch-Debugger {
	++$global:nWatchDebugger
}

# fake
function Read-Debugger {
	if ($global:step -ge $steps.Count) {throw}
	$data = $steps[$step]
	++$global:step

	if ($data -is [string]) {
		return $data
	}

	& $data.test
	$data.read
}

function Test-All {
	$global:step = 0
	$global:steps = $args[0].steps

	# test breakpoints
	Test-Debugger.ps1

	# test a script module breakpoint
	$null = Set-PSBreakpoint -Command TestModule1
	Import-Module $env:TEMP\debug.psm1
	TestModule1
}

#! define steps after functions, to avoid line shifts and noise in diffs
Test-All @{steps = @(
	@{
		test = { if ($nWatchDebugger -ne 1) {throw} }
		read = '?'
	}
	@{
		test = { if ($nWatchDebugger -ne 1) {throw} }
		read = '3'
	}
	's'
	'+3'
	's'
	'' # repeats s
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
	'$_ = 2208130916' # $_ should be set in the parent scope and be live and visible later
	'c'
	@{
		# $_ is live and visible
		test = { if ($_ -ne 2208130916) {throw} }
		read = '$_'
	}
	'c'
	'q'
)}
