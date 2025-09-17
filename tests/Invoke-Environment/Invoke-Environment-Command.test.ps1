<#
.Synopsis
	Invoke-Environment.ps1 [-Command] ... tests.

.Description
	It uses the environment variable TEST.
#>

# used temp batch files
$File = "$env:TEMP\Test-Invoke-Environment.cmd"
$File2 = "$env:TEMP\Test Invoke-Environment.cmd" # with spaces

Set-StrictMode -Version Latest

# clean
Exit-Build {
	remove $File, $File2
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
	equals $env:test 'Simple'
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
	equals $env:test 'Output'
	equals $res.Count 1
	equals $res[0] 'Some output'
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
	equals $LastExitCode 11
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
	equals $r
	equals $LastExitCode 0
	equals $env:test 'Exit42Force'
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
	equals $r 'BatchWithSpacesAndError'
	equals $LastExitCode 0
	equals $env:test 'BatchWithSpacesAndError'

	# no -Force
	$env:test = $null
	$r = Invoke-Environment "`"$File2`"" -Output
	equals $r 'BatchWithSpacesAndError'
	equals $LastExitCode 42
	equals $env:test
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
	equals $env:test1 'Argument1'
	equals $env:test2 '"Argument 2"'
}
