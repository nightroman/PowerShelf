
<#
.Synopsis
	Add-Path.ps1 tests.

.Description
	Tests use the environment variable TEST.

.Example
	Invoke-Build * Add-Path.build.ps1
#>

Set-StrictMode -Version 2

task MissingDirectory {
	$ErrorActionPreference = $err = 'Continue'
	try {
		Add-Path MissingDirectory TEST
	}
	catch { $err = $_ | Out-String }
	$err
	assert ($err -like "*\Add-Path.ps1 : Missing directory '*\MissingDirectory'.*At *\Add-Path.build.ps1:*")
}

task AddTwiceNoSlash {
	# initial path value
	$env:TEST = 'a;b;c'

	# add a new, check added
	Add-Path . TEST
	assert ($env:TEST -eq "$BuildRoot;a;b;c")

	# add the same, check not added again
	Add-Path . TEST
	assert ($env:TEST -eq "$BuildRoot;a;b;c")
}

task AddTwiceWithSlash {
	# initial path value
	$env:TEST = 'a;b;c'

	# add a new, check added
	Add-Path "$BuildRoot/" TEST
	assert ($env:TEST -eq "$BuildRoot\;a;b;c")

	# add the same, check not added again
	Add-Path "$BuildRoot/" TEST
	assert ($env:TEST -eq "$BuildRoot\;a;b;c")
}

task AddExisting {
	$env:TEST = "a;$BuildRoot;c"
	Add-Path "$BuildRoot" TEST
	assert ($env:TEST -eq "a;$BuildRoot;c")
	Add-Path "$BuildRoot/" TEST
	assert ($env:TEST -eq "a;$BuildRoot;c")

	$env:TEST = "a;$BuildRoot\;c"
	Add-Path "$BuildRoot" TEST
	assert ($env:TEST -eq "a;$BuildRoot\;c")
	Add-Path "$BuildRoot/" TEST
	assert ($env:TEST -eq "a;$BuildRoot\;c")
}
