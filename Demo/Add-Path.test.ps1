
<#
.Synopsis
	Add-Path.ps1 tests.

.Description
	Tests use the environment variable TEST.
#>

Set-StrictMode -Version 2

task MissingDirectory {
	$ErrorActionPreference = 'Continue'
	($e = try {Add-Path MissingDirectory TEST} catch {$_ | Out-String})
	assert ($e -like "*\Add-Path.ps1 : Missing directory '*\MissingDirectory'.*At *\Add-Path.test.ps1:*")
}

task AddTwiceNoSlash {
	# initial path value
	$env:TEST = 'a;b;c'

	# add a new, check added
	Add-Path . TEST
	equals $env:TEST "$BuildRoot;a;b;c"

	# add the same, check not added again
	Add-Path . TEST
	equals $env:TEST "$BuildRoot;a;b;c"
}

task AddTwiceWithSlash {
	# initial path value
	$env:TEST = 'a;b;c'

	# add a new, check added
	Add-Path "$BuildRoot/" TEST
	equals $env:TEST "$BuildRoot\;a;b;c"

	# add the same, check not added again
	Add-Path "$BuildRoot/" TEST
	equals $env:TEST "$BuildRoot\;a;b;c"
}

task AddExisting {
	$env:TEST = "a;$BuildRoot;c"
	Add-Path "$BuildRoot" TEST
	equals $env:TEST "a;$BuildRoot;c"
	Add-Path "$BuildRoot/" TEST
	equals $env:TEST "a;$BuildRoot;c"

	$env:TEST = "a;$BuildRoot\;c"
	Add-Path "$BuildRoot" TEST
	equals $env:TEST "a;$BuildRoot\;c"
	Add-Path "$BuildRoot/" TEST
	equals $env:TEST "a;$BuildRoot\;c"
}

task AddMany {
	$env:TEST = "a;C:\TEMP;c"
	Add-Path -Name TEST -Path C:\TEMP, $env:TEMP, $BuildRoot
	equals $env:TEST "$BuildRoot;$env:TEMP;a;C:\TEMP;c"
}
