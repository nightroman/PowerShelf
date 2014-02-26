
<#
.Synopsis
	Build script (https://github.com/nightroman/Invoke-Build)
#>

Set-StrictMode -Version Latest

# Package files
$Files = @(
	'..\*-*.ps1'
	'..\LICENSE.txt'
)

# Import markdown tasks ConvertMarkdown and RemoveMarkdownHtml.
# <https://github.com/nightroman/Invoke-Build/wiki/Partial-Incremental-Tasks>
Markdown.tasks.ps1

# Copy external markdown here.
task BeforeConvertMarkdown -Before ConvertMarkdown {
	Copy-Item ..\README.md .
}

# Remove temporary files.
task Clean RemoveMarkdownHtml, {
	Remove-Item z, README.md, PowerShelf.*.nupkg -Force -Recurse -ErrorAction 0
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

# Push commits with a version tag.
task PushRelease Version, {
	$changes = exec { git status --short }
	assert (!$changes) "Please, commit changes."

	exec { git push }
	exec { git tag -a "v$Version" -m "v$Version" }
	exec { git push origin "v$Version" }
}

# Push NuGet package.
task PushNuGet NuGet, {
	exec { NuGet push "PowerShelf.$Version.nupkg" }
},
Clean

# Make NuGet package.
task NuGet Package, Version, {
	$text = @'
PowerShell tools for various tasks implemented as scripts, mostly standalone.
They are designed for PowerShell v2.0 and v3.0.
'@
	# NuGet file
	Set-Content z\Package.nuspec @"
<?xml version="1.0"?>
<package xmlns="http://schemas.microsoft.com/packaging/2010/07/nuspec.xsd">
	<metadata>
		<id>PowerShelf</id>
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
