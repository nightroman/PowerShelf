<#PSScriptInfo
.VERSION 1.0.0
.AUTHOR Roman Kuzmin
.COPYRIGHT (c) Roman Kuzmin
.TAGS URL HTML Invoke Browser
.GUID b316cc92-f84f-481c-a934-94b8f8710eb3
.LICENSEURI http://www.apache.org/licenses/LICENSE-2.0
.PROJECTURI https://github.com/nightroman/PowerShelf
#>

<#
.Synopsis
	Creates and opens HTML navigating to URL.

.Description
	This command works around potential issues with complex URLs when
	Start-Process and other methods may fail. It opens a new HTML file
	navigating to the specified URL (assuming .html opens the browser).

.Parameter Uri
		URL to open in .html associated browser.

.Parameter File
		New HTML file to create and open.
		Default: "Temp:\Open-Url.html"

.Link
	https://github.com/nightroman/PowerShelf
#>

[CmdletBinding()]
param(
	[Parameter(Position=0, Mandatory=1)]
	[uri]$Uri
	,
	[ValidateNotNullOrEmpty()]
	[string]$File = 'Temp:\Open-Url.html'
)

$ErrorActionPreference = 1

Set-Content -LiteralPath $File -Value @"
<!DOCTYPE html>
<html>
<head>
<title>URL</title>
<script>
window.location.href = "$Uri"
</script>
</head>
<body>
</body>
</html>
"@

Invoke-Item -LiteralPath $File
