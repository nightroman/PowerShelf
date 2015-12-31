
<#
.Synopsis
	Tests Add-Debugger.ps1.
#>

Set-StrictMode -Version Latest

# Call Test-Add-Debugger.ps1 and compares the debug log with expected.
# The weird output file name is used in order to test special symbols.
task TestDebugger {
	# skip this for V2
	if ($PSVersionTable.PSVersion.Major -lt 3) {return}

	# log, remove it
	$log = "$env:TEMP\]'``debug``'[.log"
	if (Test-Path -LiteralPath $log) { Remove-Item -LiteralPath $log }

	# call the test
	PowerShell.exe "$BuildRoot\Test-Add-Debugger.ps1"
	equals $LASTEXITCODE 0
	assert (Test-Path -LiteralPath $log)

	# test log
	Assert-SameFile $HOME\data\Add-Debugger.test.log $log $env:MERGE

	# remove temp files
	Remove-Item -LiteralPath $log, $env:TEMP\debug.psm1 -ErrorAction 0
}
