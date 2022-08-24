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
		The expected URL forms:
			https://gist.github.com/gist-id
			https://gist.github.com/user/gist-id

.Parameter GitHubToken
		The GitHub token, default is $env:GITHUB_TOKEN.
		If it is not defined then the prompt is shown.

.Parameter Show
		Tells to show the gist web page after updating.

.Inputs
	None.

.Outputs
	None.

.Link
	https://docs.github.com/en/rest/reference/gists

.Link
	https://github.com/nightroman/PowerShelf
#>

#requires -version 3.0

param(
	[Parameter(Mandatory=1)]
	[string]$FileName
	,
	[string]$GistId
	,
	[string]$GitHubToken = $env:GITHUB_TOKEN
	,
	[switch]$Show
)

trap {$PSCmdlet.ThrowTerminatingError($_)}
$ErrorActionPreference = 'Stop'

# get token
if (!$GitHubToken) {
	$GitHubToken = Read-Host 'GitHub token'
}

# get the file content
$FileName = Resolve-Path -LiteralPath $FileName
$content = [System.IO.File]::ReadAllText($FileName)

# get the gist ID
if (!$GistId) {
	if ($content -match 'https://gist.github.com/\w+/(\w+)' -or $content -match 'https://gist.github.com/(\w+)') {
		$GistId = $matches[1]
	}
	else {
		throw 'GistId is not specified and the file does not contain a gist URL.'
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

# make request headers
$headers = @{
	Accept = 'application/vnd.github+json'
	Authorization = "Bearer $GitHubToken"
}

# send the request
[System.Net.ServicePointManager]::SecurityProtocol = "$([System.Net.ServicePointManager]::SecurityProtocol),Tls11,Tls12"
$r = Invoke-RestMethod -Uri "https://api.github.com/gists/$GistId" -Method Patch -Headers $headers -Body $body

# show the web page
if ($Show) {
	Start-Process $r.html_url
}
