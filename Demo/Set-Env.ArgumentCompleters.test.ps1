<#
.Synopsis
	Set-Env.ArgumentCompleters.ps1 tests.
#>

Set-StrictMode -Version 2
Set-Env.ArgumentCompleters.ps1

function Invoke-Complete([Parameter()]$line, $caret=$line.Length) {
	Write-Host "Complete: $line" -ForegroundColor Magenta
	(TabExpansion2 $line $caret).CompletionMatches
}

task NameEmpty {
	$s = Get-ChildItem env:
	$r = Invoke-Complete 'set-env '
	equals $r.Count $s.Count
}

task NamePrefix {
	$s = Get-ChildItem env:\t*
	$r = Invoke-Complete 'set-env t'
	equals $r.Count $s.Count

	$4 = $r | ? CompletionText -eq TEMP
	equals $4.ListItemText TEMP
	equals $4.ResultType ([System.Management.Automation.CompletionResultType]::Variable)
	equals $4.ToolTip $env:TEMP
}

task ValueEmpty {
	$s = Get-ChildItem
	$r = Invoke-Complete 'set-env q1 '
	equals $r.Count ($s.Count + 1) # dot is added

	# dot
	$4 = $r[0]
	equals $4.CompletionText $BuildRoot
	equals $4.ListItemText .
	equals $4.ResultType ([System.Management.Automation.CompletionResultType]::ProviderContainer)
	equals $4.ToolTip $BuildRoot

	# folder
	$4 = $r | ? ListItemText -eq Expand-Diff
	equals $4.CompletionText $BuildRoot\Expand-Diff
	equals $4.ResultType ([System.Management.Automation.CompletionResultType]::ProviderContainer)
	equals $4.ToolTip $BuildRoot\Expand-Diff

	# file
	$4 = $r | ? ListItemText -eq README.md
	equals $4.CompletionText $BuildRoot\README.md
	equals $4.ResultType ([System.Management.Automation.CompletionResultType]::ProviderItem)
	equals $4.ToolTip $BuildRoot\README.md
}

task ValuePrefix {
	$r = Invoke-Complete 'set-env q1 set-en'
	equals $r.Count 2 # dot is not added
	equals $r[0].CompletionText $BuildRoot\Set-Env.ArgumentCompleters.test.ps1
	equals $r[1].CompletionText $BuildRoot\Set-Env.test.ps1
}
