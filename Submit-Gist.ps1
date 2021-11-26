<#
.Synopsis
	Submits a file to its GitHub gist repository.
	Author: Roman Kuzmin

.Description
	Requirements:
	* The gist exists and you are the owner.
	* Git client is installed, configured, and available in the path.
	* Use PowerShell.exe, git may require some console based interaction.

	The script uses the local gist repository $HOME\gist-{GistId}. If it does
	not exist then it is cloned. Then the file is copied to this repository.
	Then git `add`, `status`, `commit`, and `push` are invoked.

	A just cloned local gist repository is removed after submission unless the
	switch Keep is used. An existing local repository is not removed.

	See also Update-Gist.ps1 which has its pros and cons.

.Parameter FileName
		The file to be submitted (existing is updated, new is added).

.Parameter GistId
		The existing gist ID. If it is not specified then the script searches
		for a gist URL in the file, the first matching URL is used for the ID.
		The expected URL is either
			https://gist.github.com/user/gist-id
		or
			https://gist.github.com/gist-id

.Parameter Keep
		Tells to keep the local gist repository.

.Inputs
	None.

.Outputs
	git output.

.Link
	https://github.com/nightroman/PowerShelf
#>

param(
	[Parameter(Mandatory=1)]
	[string]$FileName,
	[string]$GistId,
	[switch]$Keep
)

trap {$PSCmdlet.ThrowTerminatingError($_)}
$ErrorActionPreference = 'Stop'

function exec($command) {
	. $command
	if ($LASTEXITCODE) {throw "Command {$command} exited with code $LASTEXITCODE."}
}

$FileName = Resolve-Path -LiteralPath $FileName

# extract the gist ID from the file
if (!$GistId) {
	foreach($_ in Get-Content -LiteralPath $FileName) {
		if ($_ -match 'https://gist.github.com/\w+/(\w+)' -or $_ -match 'https://gist.github.com/(\w+)') {
			$GistId = $matches[1]
			break
		}
	}
	if (!$GistId) {throw 'GistId is not specified and the file does not contain the gist URL.'}
}
$repo = "gist-$GistId"

Push-Location -LiteralPath $HOME
try {
	# clone the repository
	if (Test-Path -LiteralPath $repo) {
		$Keep = $true
	}
	else {
		exec { git clone "https://gist.github.com/$GistId.git" $repo }
	}

	Push-Location -LiteralPath $repo
	try {
		# copy the file to the repository
		Copy-Item -LiteralPath $FileName . -Force

		# add
		exec { git add . }

		# status
		$status = exec { git status -s }

		# nothing?
		if (!$status) {
			Write-Host -ForegroundColor Cyan "Nothing is changed."
			return
		}

		# commit
		exec { git commit -m ([System.IO.Path]::GetFileName($FileName)) }

		# push
		exec { git push }
	}
	finally {
		Pop-Location

		# remove the local repository
		if (!$Keep) {
			Remove-Item -LiteralPath $repo -Force -Recurse
		}
	}
}
finally {
	Pop-Location
}
