
<#
.Synopsis
	Invoke-Environment.ps1 tests.

.Description
	It uses the environment variable TEST.
#>

# used temp batch files
$File = "$env:TEMP\Test-Invoke-Environment.cmd"
$File2 = "$env:TEMP\Test Invoke-Environment.cmd" # with spaces

Set-StrictMode -Version Latest

# called in the end, removes the temp file
function Exit-Build {
	Remove-Item -LiteralPath $File, $File2 -ErrorAction 0 -Verbose
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
	$r = Invoke-Environment $File -Force
	assert ($null -eq $r)
	assert ($LastExitCode -eq 0)
	assert ($env:test -eq 'Exit42Force') $env:test
}

<#
This example command used to fail:

	Invoke-Environment '"%VS100COMNTOOLS%\vsvars32.bat"' -Force

The space before `$Command` is significant:

	cmd /c " $Command ..."
#>
task BatchWithSpacesAndError {
	# new batch
	Set-Content $File2 @'
@echo off
echo BatchWithSpacesAndError
set TEST=BatchWithSpacesAndError
exit /b 42
'@

	# with -Force
	$env:test = $null
	$r = Invoke-Environment "`"$File2`"" -Force -Output
	assert ($r -eq 'BatchWithSpacesAndError')
	assert ($LastExitCode -eq 0)
	assert ($env:test -eq 'BatchWithSpacesAndError')

	# no -Force
	$env:test = $null
	$r = Invoke-Environment "`"$File2`"" -Output
	assert ($r -eq 'BatchWithSpacesAndError')
	assert ($LastExitCode -eq 42)
	assert ($null -eq $env:test)
}

<#
The test passes two arguments in the batch file, without and with spaces.
Unfortunately arguments with spaces are passed together with `"`.
Thus, Invoke-Environment is designed for mostly simple cases.
#>
task BatchWithArguments {
	# new batch
	Set-Content $File2 @'
set TEST1=%1
set TEST2=%2
'@

	# pass some arguments
	$env:test1 = $null
	$env:test2 = $null
	Invoke-Environment "`"$File2`" Argument1 `"Argument 2`"" -Force
	assert ($env:test1 -eq 'Argument1')
	assert ($env:test2 -eq '"Argument 2"')
}
