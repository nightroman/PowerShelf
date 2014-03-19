
<#
.Synopsis
	Sync-Directory.ps1 tests.
#>

Set-StrictMode -Version Latest

task Missing {
	($e = try {Sync-Directory missing1 missing2} catch {$_})
	assert ($e -like "Directories '*\missing1' and '*\missing2' do not exist.*")
}

task Missing1 {
	Remove-Item $env:TEMP\[z] -Force -Recurse -ErrorAction 0

	function Write-Warning {
		$r.Warning = $args[0]
	}
	function Get-Choice2 {
		$r.Caption = $args[0]
		$choice
	}
	Set-Alias Get-Choice Get-Choice2

	$r = @{}
	$choice = 1
	Sync-Directory $env:TEMP\z .
	assert ($r.Warning -like "Directory 1 '*\z' does not exist.")
	assert ($r.Caption -like "Mirror 2->1 '$BuildRoot' to '*\z'")
	assert (!(Test-Path $env:TEMP\z))

	$r = @{}
	$choice = 0
	Sync-Directory $env:TEMP\z .
	assert ($r.Warning -like "Directory 1 '*\z' does not exist.")
	assert ($r.Caption -like "Mirror 2->1 '$BuildRoot' to '*\z'")
	assert (Test-Path $env:TEMP\z)
	assert ((Get-ChildItem).Count -eq (Get-ChildItem $env:TEMP\z).Count)

	Remove-Item $env:TEMP\z -Force -Recurse
}

task Missing2 {
	Remove-Item $env:TEMP\[z] -Force -Recurse -ErrorAction 0

	function Write-Warning {
		$r.Warning = $args[0]
	}
	function Get-Choice2 {
		$r.Caption = $args[0]
		$choice
	}
	Set-Alias Get-Choice Get-Choice2

	$r = @{}
	$choice = 1
	Sync-Directory . $env:TEMP\z
	assert ($r.Warning -like "Directory 2 '*\z' does not exist.")
	assert ($r.Caption -like "Mirror 1->2 '$BuildRoot' to '*\z'")
	assert (!(Test-Path $env:TEMP\z))

	$r = @{}
	$choice = 0
	Sync-Directory . $env:TEMP\z
	assert ($r.Warning -like "Directory 2 '*\z' does not exist.")
	assert ($r.Caption -like "Mirror 1->2 '$BuildRoot' to '*\z'")
	assert (Test-Path $env:TEMP\z)
	assert ((Get-ChildItem).Count -eq (Get-ChildItem $env:TEMP\z).Count)

	Remove-Item $env:TEMP\z -Force -Recurse
}
