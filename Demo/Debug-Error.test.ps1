
<#
.Synopsis
	Debug-Error.ps1 tests.

.Description
	The parameter Action is used for non interactive testing.
#>

task Terminating.NonTerminating.TurningOff {
	# enable debugging on errors
	Debug-Error { $script:log = 'Failed' }

	# use the try block to disable debugging in any case
	try {
		# Test 1. Non terminating errors do not trigger the breakpoint
		$script:log = ''
		Get-Item missing -ErrorAction SilentlyContinue
		assert ($log -eq '')

		# Test 2. Terminating errors trigger the breakpoint
		$script:log = ''
		try { Get-Item missing -ErrorAction Stop }
		catch {}
		assert ($log -eq 'Failed')
	}
	finally {
		# disable debugging on errors
		Debug-Error -Off
	}

	# Test 3. Debugging is turned off
	$script:log = ''
	try { Get-Item missing -ErrorAction Stop }
	catch {}
	assert ($log -eq '')
}
