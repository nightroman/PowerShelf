
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
	assert ($LASTEXITCODE -eq 0)
	assert (Test-Path -LiteralPath $log)

	# compare logs
	$log2 = "$env:APPDATA\debug.log"
	if (Test-Path -LiteralPath $log2) {
		$text1 = [IO.File]::ReadAllText($log)
		$text2 = [IO.File]::ReadAllText($log2)
		if ($text1 -ne $text2) {
			if ($env:MERGE -and (Test-Path $env:MERGE)) {
				& $env:MERGE $log $log2
			}
			throw "Different logs"
		}
	}
	else {
		Write-Warning "Creating missing $log2"
		Move-Item -LiteralPath $log $log2
	}

	# remove temp files
	Remove-Item -LiteralPath $log, $env:TEMP\debug.psm1 -ErrorAction 0
}
