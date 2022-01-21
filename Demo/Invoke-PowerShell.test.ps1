<#
.Synopsis
	Tests Invoke-PowerShell.ps1.
#>

$Version = $PSVersionTable.PSVersion
${3.0.0} = [Version]'3.0.0'
${6.0.0} = [Version]'6.0.0'

task SameVersion {
	($r = exec {Invoke-PowerShell.ps1 -NoProfile -Command '$PSVersionTable.PSVersion.ToString()'})
	equals $r "$Version"
}

task ScriptBlockAsEncodedCommand {
	$script = {[Environment]::GetCommandLineArgs()}
	$base64 = 'WwBFAG4AdgBpAHIAbwBuAG0AZQBuAHQAXQA6ADoARwBlAHQAQwBvAG0AbQBhAG4AZABMAGkAbgBlAEEAcgBnAHMAKAApAA=='

	($r = Invoke-PowerShell.ps1 $script)
	if ($Version -ge ${3.0.0}) {
		if ($Host.Name -eq 'ConsoleHost')
		{
			equals $r.Count 7
			equals "$($r[1..6])" "-encodedCommand $base64 -inputFormat xml -outputFormat xml"
		}
		else {
			#_220116_pz FarHost so far, not sure why -noninteractive is added
			equals $r.Count 8
			equals "$($r[1..7])" "-noninteractive -encodedCommand $base64 -inputFormat xml -outputFormat xml"
		}
	}
	else {
		equals $r.Count 9
		equals "$($r[1..8])" "-Version 2 -encodedCommand $base64 -inputFormat xml -outputFormat xml"
	}

	($r = Invoke-PowerShell.ps1 -OutputFormat Text $script)
	if ($Version -ge ${3.0.0}) {
		if ($Host.Name -eq 'ConsoleHost')
		{
			equals $r.Count 7
			equals "$($r[1..6])" "-outputFormat text -encodedCommand $base64 -inputFormat xml"
		}
		else {
			#_220116_pz
			equals $r.Count 8
			equals "$($r[1..7])" "-noninteractive -outputFormat text -encodedCommand $base64 -inputFormat xml"
		}
	}
	else {
		equals $r.Count 9
		equals "$($r[1..8])" "-Version 2 -outputFormat text -encodedCommand $base64 -inputFormat xml"
	}
}

# Issue: `Invoke-PowerShell {.\missing.ps1} | Out-String` emits errors.
# v1.0.2 improves its handling by `trap {Write-Error -ErrorRecord $_}`.
# NB Without Out-String or $ErrorActionPreference Stop it works.
task case1_1 {
	$res, $err = ''
	try {
		$res = Invoke-PowerShell.ps1 {.\missing.ps1} | Out-String
	}
	catch {
		$err = $_
	}
	'$res', $res, '$err', $err | Out-String

	if ($Version -lt ${6.0.0}) {
		equals $res ''
		equals $err.FullyQualifiedErrorId CommandNotFoundException
		equals $err.InvocationInfo.ScriptName $BuildFile
	}
	else {
		equals $res ''
		equals $err $null
	}
}

# Case 1 works without Out-String.
task case1_2 {
	Invoke-PowerShell.ps1 {.\missing.ps1}
}

# Case 1 works with error preference Continue and Out-String.
task case1_3 {
	$ErrorActionPreference = 'Continue'
	Invoke-PowerShell.ps1 {.\missing.ps1} | Out-String
}
