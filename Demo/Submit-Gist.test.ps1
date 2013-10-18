
<#
.Synopsis
	Submit-Gist.ps1 tests.

.Description
	Task SubmitNotChanged is hardcoded for gist-1303971 C:\ROM\APS\Markdown.tasks.ps1
#>

task MissingFile {
	$ErrorActionPreference = $err = 'Continue'
	try {
		Submit-Gist.ps1 MissingFile
	}
	catch { $err = $_ | Out-String }
	$err
	assert ($err -like "*\Submit-Gist.ps1 : Cannot find path 'MissingFile' because it does not exist.*At *\Submit-Gist.test.ps1:*")
}

task NoGistId {
	$ErrorActionPreference = $err = 'Continue'
	try {
		Submit-Gist.ps1 $BuildFile
	}
	catch { $err = $_ | Out-String }
	$err
	assert ($err -like "*\Submit-Gist.ps1 : Found no gist URL in '*\Submit-Gist.test.ps1'.*At *\Submit-Gist.test.ps1:*")
}

task SafeSubmitNotChanged @{SubmitNotChanged=1}
task SubmitNotChanged {
	$repo1303971 = "$HOME\gist-1303971"

	# remove manually if exists
	assert (![IO.Directory]::Exists($repo1303971)) "Please remove '$repo1303971'"

	# fake Write-Host
	$res1 = @{text=''}
	function Write-Host($Object, $ForegroundColor) { $res1.text = $Object }

	### 1.
	Write-Build Cyan "submit - yet no repo, do not keep"
	$res2 = Submit-Gist.ps1 C:\ROM\APS\Markdown.tasks.ps1 | .{process{$_.Trim()}}

	# repo must be removed
	assert (![IO.Directory]::Exists($repo1303971))

	# check messages
	$res1.text
	assert ($res1.text -eq "Nothing is changed.")
	$res2
	assert ($res2 = "Cloning into 'gist-1303971'...")

	### 2.
	Write-Build Cyan "submit - yet no repo, keep"
	$res1.text = ''
	$res2 = Submit-Gist.ps1 C:\ROM\APS\Markdown.tasks.ps1 -Keep

	# repo must exist
	assert ([IO.Directory]::Exists($repo1303971))

	# check messages
	$res1.text
	assert ($res1.text -eq "Nothing is changed.")
	$res2
	assert ($res2 = "Cloning into 'gist-1303971'...")

	### 3.
	Write-Build Cyan "submit - repo exists, do not keep"
	$res1.text = ''
	$res2 = Submit-Gist.ps1 C:\ROM\APS\Markdown.tasks.ps1

	# repo still must exist
	assert ([IO.Directory]::Exists($repo1303971))

	# check messages
	$res1.text
	assert ($res1.text -eq "Nothing is changed.")
	$res2
	assert (!$res2) # because it was not cloned

	# remove repo
	Write-Build Cyan "removing repo..."
	Remove-Item -LiteralPath $repo1303971 -Recurse -Force
}
