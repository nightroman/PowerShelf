
<#
.Synopsis
	Build script (https://github.com/nightroman/Invoke-Build)
#>

# Convert markdown files to HTML.
# <http://johnmacfarlane.net/pandoc/>
task Markdown {
	exec {pandoc.exe --standalone --from=gfm --output=README.htm ../README.md --metadata=pagetitle=README}
	exec {pandoc.exe --standalone --from=gfm --output=Release-Notes.htm Release-Notes.md --metadata=pagetitle=Release-Notes}
}

# Remove temp files
task Clean {
	remove z, README.htm, Release-Notes.htm, PowerShelf.*.nupkg
}

# Make package directory z\tools.
task Package Markdown, {
	# temp package folder
	remove z
	$null = mkdir z\tools

	# copy files
	Copy-Item -Destination z\tools `
	..\*-*.ps1,
	..\LICENSE.txt,
	README.htm,
	Release-Notes.htm
}

# Get version.
task Version {
	assert ([IO.File]::ReadAllText('Release-Notes.md') -match '##\s+v(\d+\.\d+\.\d+)')
	($script:Version = $Matches[1])
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
	exec { NuGet push "PowerShelf.$Version.nupkg" -source nuget.org }
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
		<developmentDependency>true</developmentDependency>
	</metadata>
</package>
"@
	# pack
	exec { NuGet.exe pack z\Package.nuspec -NoPackageAnalysis }
}
