<#
.Synopsis
	Set-Env.ps1 tests.
#>

Set-StrictMode -Version 2

$Warnings = [System.Collections.Generic.List[string]]::new()

function Write-Warning2($Message) {
	$Warnings.Add($Message)
	Write-Host $Message -ForegroundColor Yellow
}

function Reset-Test {
	[System.Environment]::SetEnvironmentVariable('q1', '', 'User')
	[System.Environment]::SetEnvironmentVariable('q1', '', 'Machine')
	[System.Environment]::SetEnvironmentVariable('q1', '', 'Process')
	Set-Alias Write-Warning Write-Warning2
	$Warnings.Clear()
}

task User {
	. Reset-Test

	Set-Env q1 UserValue
	equals $env:q1 UserValue
	equals $Warnings.Count 0

	$r = Invoke-PowerShell -Command '$env:q1'
	equals $r UserValue

	Set-Env q1
	equals $env:q1 $null
	equals $Warnings.Count 0

	$r = Invoke-PowerShell -Command '$env:q1'
	equals $r $null

	. Reset-Test
}

task Machine {
	. Reset-Test

	Set-Env q1 MachineValue -Machine
	equals $env:q1 MachineValue
	equals $Warnings.Count 0

	$r = Invoke-PowerShell -Command '$env:q1'
	equals $r MachineValue

	Set-Env q1 -Machine
	equals $env:q1 $null
	equals $Warnings.Count 0

	$r = Invoke-PowerShell -Command '$env:q1'
	equals $r $null

	. Reset-Test
}

task UserValueOverrides {
	. Reset-Test

	# set user
	Set-Env q1 UserValue
	equals $env:q1 UserValue
	equals $Warnings.Count 0

	$r = Invoke-PowerShell -Command '$env:q1'
	equals $r UserValue

	# set machine
	Set-Env q1 MachineValue -Machine
	equals $env:q1 UserValue
	equals $Warnings.Count 1
	equals $Warnings[0] "Set-Env: Existing User variable 'q1' takes over."

	$r = Invoke-PowerShell -Command '$env:q1'
	equals $r UserValue

	. Reset-Test
}

task MachineValueOverrides {
	. Reset-Test

	# set machine
	Set-Env q1 MachineValue -Machine
	equals $env:q1 MachineValue
	equals $Warnings.Count 0

	$r = Invoke-PowerShell -Command '$env:q1'
	equals $r MachineValue

	# set user
	Set-Env q1 UserValue
	equals $env:q1 UserValue
	equals $Warnings.Count 0

	$r = Invoke-PowerShell -Command '$env:q1'
	equals $r UserValue

	# remove user
	Set-Env q1
	equals $env:q1 MachineValue
	equals $Warnings.Count 1
	equals $Warnings[0] "Set-Env: Existing Machine variable 'q1' takes over."

	$r = Invoke-PowerShell -Command '$env:q1'
	equals $r MachineValue

	. Reset-Test
}
