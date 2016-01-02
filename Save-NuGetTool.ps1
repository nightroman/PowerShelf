
<#
.Synopsis
	Downloads a NuGet package and extracts /tools.
	Author: Roman Kuzmin

.Description
	The command downloads PackageId.zip from the NuGet Gallery to the current
	location and extracts /tools as the directory PackageId. If these items
	exist remove them manually or use another location.

.Parameter PackageId
	Specifies the package ID.

.Link
	https://github.com/nightroman/PowerShelf
#>

param([Parameter()]$PackageId)
$ErrorActionPreference = 'Stop'

$here = $PSCmdlet.GetUnresolvedProviderPathFromPSPath('')
$zip = "$here\$PackageId.zip"
$dir = "$here\$PackageId"
if ((Test-Path -LiteralPath $zip, $dir) -eq $true) {
	Write-Error "Remove '$zip' and '$dir' or use another directory."
}

$web = New-Object System.Net.WebClient
$web.UseDefaultCredentials = $true
try {
	$web.DownloadFile("http://nuget.org/api/v2/package/$PackageId", $zip)
}
catch {
	Write-Error "Cannot download the package : $_"
}

$shell = New-Object -ComObject Shell.Application
$from = $shell.NameSpace("$zip\tools")
if (!$from) {
	Write-Error "Missing package item '$zip\tools'."
}
$one, $two = @($from.Items())
if (!$two -and $one.Name -eq $PackageId) {
	$from = $shell.NameSpace($one.Path)
}

$null = mkdir $dir
$shell.NameSpace($dir).CopyHere($from.Items(), 4)
