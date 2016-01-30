
#requires -version 3.0

<#
.Synopsis
	Updates or creates a gist file using Invoke-RestMethod.
	Author: Roman Kuzmin

.Description
	The script updates or creates a text file in the existing GitHub gist.

	See also Submit-Gist.ps1 which has its pros and cons.

.Parameter FileName
		Specifies the file to be updated or created in the gist.
.Parameter GistId
		The existing gist ID. If it is not specified then the script searches
		for a gist URL in the file, the first matching URL is used for the ID.
		The expected URL is either
			https://gist.github.com/user/gist-id
		or
			https://gist.github.com/gist-id
		If the Credential is not specified then the first form is preferable
		because the user name is automatically provided in the login dialog.
.Parameter Credential
		Specifies a GitHub user account.
		If it is omitted then the login dialog is shown.
.Parameter Show
		Tells to show the gist web page after updating.

.Inputs
	None. Use the parameters.
.Outputs
	None.

.Link
	https://github.com/nightroman/PowerShelf
#>

param(
	[Parameter(Mandatory=1)]
	[string]$FileName,
	[string]$GistId,
	[PSCredential]$Credential,
	[switch]$Show
)

trap {$PSCmdlet.ThrowTerminatingError($_)}
$ErrorActionPreference = 'Stop'

# get the file content
$FileName = Resolve-Path -LiteralPath $FileName
$content = [System.IO.File]::ReadAllText($FileName)

# get the gist ID
$userName = ''
if (!$GistId) {
	if ($content -notmatch 'https://gist.github.com/(\w+)(?:/(\w+))?') {
		throw 'GistId is not specified and the file does not contain the gist URL.'
	}
	if ($matches[2]) {
		$userName = $matches[1]
		$GistId = $matches[2]
	}
	else {
		$GistId = $matches[1]
	}
}

# make request body
$gistFile = [System.IO.Path]::GetFileName($FileName)
$body = [System.Text.Encoding]::UTF8.GetBytes((
	@{
		'files' = @{
			$gistFile = @{
				'content' = $content
			}
		}
	} | ConvertTo-Json -Compress
))

# get request credential
if (!$Credential) {
	$Credential = Get-Credential -Message 'GitHub account' -UserName $userName
	if (!$Credential) {return}
}

# make request headers
$headers = @{
	Authorization = 'Basic ' + (
		[Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes(
			"$($Credential.UserName):$($Credential.GetNetworkCredential().Password)"
		))
	)
}

# send the request
$r = Invoke-RestMethod -Uri "https://api.github.com/gists/$GistId" -Method Patch -Headers $headers -Body $body

# show the web page
if ($Show) {
	Start-Process $r.html_url
}
