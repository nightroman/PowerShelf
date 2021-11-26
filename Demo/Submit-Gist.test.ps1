<#
.Synopsis
	Submit-Gist.ps1 tests.

.Description
	Task SubmitNotChanged is hardcoded for gist-1303971 ...\Markdown.tasks.ps1
#>

$SubmitNotChangedFile = "C:\-\zip\DEV\MarkdownDeep\Markdown.tasks.ps1"

task MissingFile {
	$ErrorActionPreference = 'Continue'
	($e = try {Submit-Gist.ps1 MissingFile} catch {$_ | Out-String})
	assert ($e -like "*\Submit-Gist.ps1 : Cannot find path 'MissingFile' because it does not exist.*At *\Submit-Gist.test.ps1:*")
}

task NoGistId {
	$ErrorActionPreference = 'Continue'
	($e = try {Submit-Gist.ps1 $BuildFile} catch {$_ | Out-String})
	assert ($e -like "*\Submit-Gist.ps1 : GistId is not specified and the file does not contain the gist URL.*At *\Submit-Gist.test.ps1:*")
}

task SafeSubmitNotChanged ?SubmitNotChanged
task SubmitNotChanged {
	$repo1303971 = "$HOME\gist-1303971"

	# remove manually if exists
	assert (![IO.Directory]::Exists($repo1303971)) "Please remove '$repo1303971'"

	# fake Write-Host
	$res1 = @{text=''}
	function Write-Host($Object, $ForegroundColor) { $res1.text = $Object }

	### 1.
	Write-Build Cyan "submit - yet no repo, do not keep"
	$res2 = Submit-Gist.ps1 $SubmitNotChangedFile | .{process{$_.Trim()}}

	# repo must be removed
	assert (![IO.Directory]::Exists($repo1303971))

	# check messages
	$res1.text
	equals $res1.text "Nothing is changed."
	$res2
	assert ($res2 = "Cloning into 'gist-1303971'...")

	### 2.
	Write-Build Cyan "submit - yet no repo, keep"
	$res1.text = ''
	$res2 = Submit-Gist.ps1 $SubmitNotChangedFile -Keep

	# repo must exist
	assert ([IO.Directory]::Exists($repo1303971))

	# check messages
	$res1.text
	equals $res1.text "Nothing is changed."
	$res2
	assert ($res2 = "Cloning into 'gist-1303971'...")

	### 3.
	Write-Build Cyan "submit - repo exists, do not keep"
	$res1.text = ''
	$res2 = Submit-Gist.ps1 $SubmitNotChangedFile

	# repo still must exist
	assert ([IO.Directory]::Exists($repo1303971))

	# check messages
	$res1.text
	equals $res1.text "Nothing is changed."
	$res2
	assert (!$res2) # because it was not cloned

	# remove repo
	Write-Build Cyan "removing repo..."
	Remove-Item -LiteralPath $repo1303971 -Recurse -Force
}
