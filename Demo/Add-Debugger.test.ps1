
<#
.Synopsis
	Tests Add-Debugger.ps1.
#>

$Version = $PSVersionTable.PSVersion.Major
Set-StrictMode -Version Latest

# Call Test-Add-Debugger.ps1 and compares the debug log with expected.
# The weird output file name is used in order to test special symbols.
task TestDebugger {
	# skip this for V2
	if ($Version -lt 3) {return}

	# log, remove it
	$log = "$env:TEMP\]'``debug``'[.log"
	if (Test-Path -LiteralPath $log) { Remove-Item -LiteralPath $log }

	# call the test
	Invoke-PowerShell -NoProfile -Command "$BuildRoot\Test-Add-Debugger.ps1"
	equals $LASTEXITCODE 0
	assert (Test-Path -LiteralPath $log)

	# test log
	# v6-beta.7: changed EOL in position messages
	$sample = if ($Version -ge 6) {"$HOME\data\Add-Debugger.v6.test.log"} else {"$HOME\data\Add-Debugger.test.log"}
	Assert-SameFile $sample $log $env:MERGE

	# remove temp files
	Remove-Item -LiteralPath $log, $env:TEMP\debug.psm1 -ErrorAction 0
}
