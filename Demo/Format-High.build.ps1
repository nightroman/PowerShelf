
<#
.Synopsis
	Format-High.ps1 tests.

.Example
	Invoke-Build * Format-High.build.ps1
#>

Set-StrictMode -Version 2

task Examples {
	# file system items
	Get-ChildItem $home | Format-High

	# verb names, custom width
	Get-Verb | Format-High Verb 80

	# custom expression and width
	Get-Process | Format-High {$_.Name + ':' + $_.WS} 80

	# process names in colors based on working sets
	Get-Process | Format-High Name 80 {@{f=if($_.WS -gt 10mb){'red'}else{'green'}}}
}

task UnknownArguments {
	$ErrorActionPreference = $err = 'Continue'
	try {
		1 | Format-High.ps1 -Unknown foo
	}
	catch { $err = $_ | Out-String }
	$err
	assert ($err -like '*\Format-High.ps1 : Unknown arguments: -Unknown foo*\Format-High.build.ps1:*')
}

task BadProperty {
	$ErrorActionPreference = $err = 'Continue'
	try {
		1..11 | Format-High.ps1 {throw 'Oops.'}
	}
	catch { $err = $_ | Out-String }
	$err
	assert ($err -like '*\Format-High.ps1 : Error on Property evaluation: Oops.*\Format-High.build.ps1:*')
}

task BadColorThrow {
	$ErrorActionPreference = $err = 'Continue'
	try {
		1..11 | Format-High.ps1 -Color {throw 'Oops.'}
	}
	catch { $err = $_ | Out-String }
	$err
	assert ($err -like '*\Format-High.ps1 : Error on Color evaluation: Oops.*\Format-High.build.ps1:*')
}

task BadColorKeyButWorks {
	# Write-Host accepts crap parameters due to ValueFromRemainingArguments
	1..11 | Format-High.ps1 -Color {if ($_ -le 5) {@{}} else {@{bad='bad'}}}
}
