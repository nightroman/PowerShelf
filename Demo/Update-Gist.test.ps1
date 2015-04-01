
<#
.Synopsis
	Update-Gist.ps1 tests.

.Description
	The task UpdateGist uses the hardcoded gist.
#>

if ($PSVersionTable.PSVersion.Major -lt 3) {
	task dummy {'No tests for PowerShell 2.0'}
	return
}

Set-StrictMode -Version Latest

task MissingFile {
	$ErrorActionPreference = 'Continue'
	($e = try {Update-Gist.ps1 MissingFile} catch {$_ | Out-String})
	assert ($e -like "*\Update-Gist.ps1 : Cannot find path 'MissingFile' because it does not exist.*At *\Update-Gist.test.ps1:*")
}

task NoGistId {
	$ErrorActionPreference = 'Continue'
	($e = try {Update-Gist.ps1 $BuildFile} catch {$_ | Out-String})
	assert ($e -like "*\Update-Gist.ps1 : GistId is not specified and the file does not contain the gist URL.*At *\Update-Gist.test.ps1:*")
}

task UpdateGist {
	$gistId = '95d318d6a34927f74eba'
	$gistFile = 'try.txt'

	$credential = Import-Clixml -LiteralPath "$HOME\data\GitHub.clixml"
	($content = @"
https://gist.github.com/$gistId
тест $(Get-Date)
"@)
	$file = "$env:TEMP\$gistFile"
	[System.IO.File]::WriteAllText($file, $content, [System.Text.Encoding]::UTF8)

	# update
	Update-Gist.ps1 $file -Credential $credential

	# get and check
	$r = Invoke-RestMethod -Uri https://api.github.com/gists/95d318d6a34927f74eba
	($content2 = $r.files.$GistFile.content.Replace("`n", "`r`n"))
	assert ($content -ceq $content2)

	[System.IO.File]::Delete($file)
}
