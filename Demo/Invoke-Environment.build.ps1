
<#
.Synopsis
	Invoke-Environment.ps1 tests.

.Description
	It uses the environment variable TEST.

.Example
	Invoke-Build * Invoke-Environment.build.ps1
#>

# used temp batch file
$File = "$env:TEMP\Test-Invoke-Environment.cmd"

Set-StrictMode -Version 2

# called in the end, removes the temp file
function Exit-BuildScript {
	Remove-Item -LiteralPath $File -ErrorAction 0 -Verbose
}

task Simple {
	# new batch
	Set-Content $File @'
echo Some output
set TEST=Simple
'@

	# invoke and test
	$env:test = $null
	$res = Invoke-Environment $File
	assert ($env:test -eq 'Simple')
	assert (!$res) $res
}

task Output {
	# new batch
	Set-Content $File @'
@echo off
echo Some output
set TEST=Output
'@

	# invoke and test
	$env:test = $null
	$res = @(Invoke-Environment $File -Output)
	assert ($env:test -eq 'Output')
	assert ($res.Count -eq 1) $res.Count
	assert ($res[0] -eq 'Some output') ($res[0])
}

task Exit11Stop {
	# new batch
	Set-Content $File @'
echo Some output
set TEST=Exit11Stop
exit /b 11
'@

	# invoke and test
	$env:test = $null
	Invoke-Environment $File
	assert (!$env:test) $env:test
	assert ($LastExitCode -eq 11)
}

task Exit42Force {
	# new batch
	Set-Content $File @'
echo Some output
set TEST=Exit42Force
exit /b 42
'@

	# invoke and test
	$env:test = $null
	Invoke-Environment $File -Force
	assert ($env:test -eq 'Exit42Force') $env:test
	assert ($LastExitCode -eq 0)
}
