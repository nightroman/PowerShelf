
<#
.Synopsis
	Build script (https://github.com/nightroman/Invoke-Build)
#>

Set-StrictMode -Version Latest

# Package files
$Files = @(
	'..\..\Add-Debugger.ps1'
	'..\..\Debug-Error.ps1'
	'..\..\Show-Coverage.ps1'
	'..\..\Test-Debugger.ps1'
	'..\..\Trace-Debugger.ps1'
	'..\..\LICENSE.txt'
)

# Import markdown tasks ConvertMarkdown and RemoveMarkdownHtml.
# <https://github.com/nightroman/Invoke-Build/wiki/Partial-Incremental-Tasks>
Markdown.tasks.ps1

# Remove temporary files.
task Clean RemoveMarkdownHtml, {
	Remove-Item z, NuGetDebugTools.*.nupkg -Force -Recurse -ErrorAction 0
}

# Make package directory z\tools.
task Package ConvertMarkdown, {
	# temp package folder
	Remove-Item [z] -Force -Recurse
	$null = mkdir z\tools

	# copy files
	Copy-Item $Files z\tools

	# move generated files
	Move-Item -Destination z\tools `
	.\README.htm,
	.\Release-Notes.htm
}

# Get version.
task Version {
	assert ([IO.File]::ReadAllText('Release-Notes.md') -match '##\s+v(\d+\.\d+\.\d+)')
	$script:Version = $Matches[1]
	$Version
}

# Make NuGet package.
task NuGet Package, Version, {
	$text = @'
Simple and yet effective script debugging, tracing, coverage, and other tools.
They are designed for any PowerShell host and may be used in the NuGet console
for debugging and testing NuGet and Visual Studio specific scripts.
'@
	# NuGet file
	Set-Content z\Package.nuspec @"
<?xml version="1.0"?>
<package xmlns="http://schemas.microsoft.com/packaging/2010/07/nuspec.xsd">
	<metadata>
		<id>NuGetDebugTools</id>
		<version>$Version</version>
		<owners>Roman Kuzmin</owners>
		<authors>Roman Kuzmin</authors>
		<projectUrl>https://github.com/nightroman/PowerShelf</projectUrl>
		<licenseUrl>http://www.apache.org/licenses/LICENSE-2.0</licenseUrl>
		<requireLicenseAcceptance>false</requireLicenseAcceptance>
		<summary>$text</summary>
		<description>$text</description>
		<tags>NuGet PowerShell Debugging Tracing Coverage Tools</tags>
	</metadata>
</package>
"@
	# pack
	exec { NuGet.exe pack z\Package.nuspec -NoPackageAnalysis }
}
