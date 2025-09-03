<#PSScriptInfo
.VERSION 0.0.1
.AUTHOR Roman Kuzmin
.COPYRIGHT (c) Roman Kuzmin
.TAGS HTTP Server HttpListener
.GUID bebe6fb7-4308-4bf0-8c3a-d521eebba6f5
.PROJECTURI https://github.com/nightroman/PowerShelf
.LICENSEURI http://www.apache.org/licenses/LICENSE-2.0
#>

<#
.Synopsis
	Starts HTTP server with routing script blocks.

.Description
	Route handler helper commands and variables:

		Read-Content
		Get-Headers
		Get-Query

		$Context  [System.Net.HttpListenerContext]
		$Request  [System.Net.HttpListenerRequest]
		$Response [System.Net.HttpListenerResponse]

.Parameter Prefix
		HttpListener prefix.
		Examples:
			http://localhost:8080/
			http://127.0.0.1:8080/

.Parameter Routes
		Route tags and handlers, hashtable or dictionary.

		Keys are route tags:

			GET /
			POST /test

		Values are route request handlers, script blocks.

.Link
	https://github.com/nightroman/PowerShelf
#>

[CmdletBinding()]
param(
	[Parameter(Position=0, Mandatory=$true)]
	[string]$Prefix
	,
	[Parameter(Position=1, Mandatory=$true)]
	[System.Collections.IDictionary]$Routes
)

<#
.Synopsis
	Reads HTTP request content as string.
#>
function Read-Content {
	[CmdletBinding()]
	param(
		[System.Text.Encoding]$Encoding = [System.Text.Encoding]::UTF8
	)
    $reader = [System.IO.StreamReader]::new($Request.InputStream, $Encoding)
    try { $reader.ReadToEnd() }
    finally { $reader.Close() }
}

<#
.Synopsis
	Gets $Request.Headers as [hashtable].
#>
function Get-Headers {
	[CmdletBinding()]param()
	Convert-NameValue $Request.Headers
}

<#
.Synopsis
	Gets $Request.QueryString as [hashtable].
#>
function Get-Query {
	[CmdletBinding()]param()
	Convert-NameValue $Request.QueryString
}

<#
.Synopsis
	Converts [NameValueCollection] to [hashtable].
#>
function Convert-NameValue {
	[CmdletBinding()]
	param(
		[System.Collections.Specialized.NameValueCollection]$Source
	)
	$data = [ordered]@{}
	foreach($k in $Source.AllKeys) {
		$data.Add($k, $Source.GetValues($k)[0])
	}
	$data
}

function __write_string([string]$Body) {
    $data = [System.Text.Encoding]::UTF8.GetBytes($Body)
	$Response.ContentLength64 = $data.Length
	$Response.OutputStream.Write($data, 0, $data.Length)
	$Response.OutputStream.Close()
}

$ErrorActionPreference = 1

if (!$Prefix.EndsWith('/')) {
	$Prefix = "$Prefix/"
}

Write-Host $Prefix
$Host.UI.RawUI.WindowTitle = $Prefix

$HttpListener = [System.Net.HttpListener]::new()
$HttpListener.Prefixes.Add($Prefix)
$HttpListener.Start()

:loop for(; $HttpListener.IsListening; $Response.Close()) {
	$Context = $HttpListener.GetContext()
	$Request = $Context.Request
	$Response = $Context.Response

	Write-Host "$($Request.HttpMethod) $($Request.Url)"

	# routes
	foreach($_ in $Routes.GetEnumerator()) {
		$private:method, $private:path = $_.Key.Split(' ', 2, 'RemoveEmptyEntries')
		if ($Request.HttpMethod -eq $method -and $Request.Url.AbsolutePath -eq $path) {
			try {
				$data = & $_.Value
			}
			catch {
				$Response.StatusCode = 500
				$data = "500 Internal Server Error: $_`n$($_.InvocationInfo.PositionMessage.Trim())"
				Write-Host $data -ForegroundColor Red
			}
		    __write_string $data
			continue loop
		}
	}

	# 404
    $Response.StatusCode = 404
    __write_string '404 Not Found'
}
