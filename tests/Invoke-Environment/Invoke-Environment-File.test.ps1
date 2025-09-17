<#
.Synopsis
	Invoke-Environment.ps1 -File ... [-Arguments ...] tests.
#>

Enter-BuildTask {
	$env:param1 = $null
	$env:param2 = $null
	$env:value1 = $null
}

# we quote strings with spaces
task space {
	Invoke-Environment.ps1 -File 'test me.cmd' -Arguments 'arg 1', arg2 -Output
	equals $env:param1 '"arg 1"'
	equals $env:value1 'arg 1'
	equals $env:param2 arg2
}

# we ignore (), test them, there are such paths
task round_brackets {
	Invoke-Environment.ps1 -File 'test me.cmd' -Arguments '(x86)', arg2 -Output
	equals $env:param1 '(x86)'
	equals $env:value1 '(x86)'
	equals $env:param2 arg2
}
