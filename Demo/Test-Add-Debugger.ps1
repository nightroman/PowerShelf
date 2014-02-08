
<#
.Synopsis
	Tests Add-Debugger.ps1

.Description
	Requires Add-Debugger.ps1 and Test-Debugger.ps1 in the path.

	This test is interactive. When it is invoked the debugger dialog appears.
	The main console is used for watching the debug output in the log file.
	Type debugger commands and watch the output. The test never ends due to
	Get-Content -Wait. Press [Ctrl-C] when you are done in order to exit.

.Notes
	In fact, this test shows how to debug PowerShell code when the built-in
	debugger is not available. Add-Debugger.ps1 is simple and yet effective.
#>

# ensure empty debug log
'' > $env:TEMP\debug.log

# invoke with debugger asynchronously
$ps = [PowerShell]::Create()
$null = $ps.AddScript({
	# debugger
	Add-Debugger.ps1

	# fake Write-Host
	function Write-Host { $args >> $env:TEMP\debug.log }

	# set test breakpoints
	Test-Debugger.ps1

	# invoke with debugger
	Test-Debugger.ps1
})
$null = $ps.BeginInvoke()

# watch debug log
try {
	Get-Content $env:TEMP\debug.log -Wait
}
finally {
	# remove debug on [Ctrl-C]
	Remove-Item $env:TEMP\debug.log -ErrorAction 0
}
