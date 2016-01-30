
<#
.Synopsis
	Format-High.ps1 tests.
#>

Set-StrictMode -Version Latest

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

task BadParameter {
	$ErrorActionPreference = 'Continue'
	($r = try {1 | <##> Format-High.ps1 -Unknown foo} catch {$_})
	assert $r.InvocationInfo.PositionMessage.Contains('<##>')
	equals $r.FullyQualifiedErrorId 'NamedParameterNotFound,Format-High.ps1'
}

task BadProperty {
	$ErrorActionPreference = 'Continue'
	($r = try {1..11 | <##> Format-High.ps1 {throw 'Oops.'}} catch {$_})
	assert $r.InvocationInfo.PositionMessage.Contains('<##>')
	equals $r.FullyQualifiedErrorId 'Error on Property evaluation: Oops.,Format-High.ps1'
}

task BadColorThrow {
	$ErrorActionPreference = 'Continue'
	($r = try {1..11 | <##> Format-High.ps1 -Color {throw 'Oops.'}} catch {$_})
	assert $r.InvocationInfo.PositionMessage.Contains('<##>')
	equals $r.FullyQualifiedErrorId 'Error on Color evaluation: Oops.,Format-High.ps1'
}

task BadColorKeyButWorks {
	# Write-Host accepts crap parameters due to ValueFromRemainingArguments
	1..11 | Format-High.ps1 -Color {if ($_ -le 5) {@{}} else {@{bad='bad'}}}
}

# v1.2.2 Use 80 as the default width.
task NoWindowWidthAvailable {
	$ps = [powershell]::Create()
	$null = $ps.AddScript({
		$global:out = ''
		function Write-Host ($Message, [switch]$NoNewLine) {
			if ($NoNewLine) {
				$global:out += $Message
			}
			else {
				$global:out += "$Message`n"
			}
		}
		1..111 | Format-High.ps1
		$out
	})
	$out = $ps.Invoke()[0].Trim() -split '\n' #! [0] is for PS v2
	$out
	equals $out.Count 5
}
