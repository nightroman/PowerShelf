<#
.Synopsis
	Tests Add-Debugger.ps1.
#>

$Version = $PSVersionTable.PSVersion.Major
Set-StrictMode -Version Latest

# Call Test-Add-Debugger.ps1 and compare the debug log with expected.
# The weird output file name is used in order to test special symbols.
task TestDebugger {
	# log, remove it
	$log = "$env:TEMP\]'``debug``'[.log"
	if (Test-Path -LiteralPath $log) { Remove-Item -LiteralPath $log }

	# call the test
	Invoke-PowerShell -NoProfile -Command "$BuildRoot\Test-Add-Debugger.ps1"
	equals $LASTEXITCODE 0
	assert (Test-Path -LiteralPath $log)

	# test log
	$sample = "$HOME\data\Add-Debugger.$Version.test.log"
	Assert-SameFile $sample $log $env:MERGE

	# remove temp files
	Remove-Item -LiteralPath $log, $env:TEMP\debug.psm1
}
