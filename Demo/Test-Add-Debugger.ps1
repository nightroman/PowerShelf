
<#
.Synopsis
	Tests Add-Debugger.ps1 in a bare runspace with default host.

.Description
	Requires Add-Debugger.ps1 and Test-Debugger.ps1 in the path. This test is
	interactive. When it is invoked the debugger dialog and a separate console
	with debugger output appear together (in random z-order). Enter PowerShell
	and debug commands in the dialog and watch the results in the console.

.Notes
	The weird output file name is used in order to test special symbols.
#>

# make a mini script module to be tested as well
@'
# test module
function TestModule1 {
	'In TestModule1'
}
'@ > $env:TEMP\debug.psm1

# test debugging in a bare runspace
$ps = [PowerShell]::Create()
$null = $ps.AddScript({
	# add debugger
	Add-Debugger.ps1 "$env:TEMP\]'``debug``'[.log"

	# test breakpoints
	Test-Debugger.ps1 # set
	Test-Debugger.ps1 # run

	# test a script module breakpoint
	$null = Set-PSBreakpoint -Command TestModule1
	Import-Module $env:TEMP\debug.psm1
	TestModule1
})
$ps.Invoke()
$ps.Streams.Error

# remove temp files
Remove-Item -LiteralPath "$env:TEMP\]'``debug``'[.log", $env:TEMP\debug.psm1 -ErrorAction 0
