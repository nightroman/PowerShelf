<#
.Synopsis
	Build script, https://github.com/nightroman/Invoke-Build
#>

# Synopsis: Convert markdown to HTML.
task markdown {
	exec { pandoc.exe --standalone --from=gfm --output=README.htm ../README.md --metadata=pagetitle=README }
}

# Synopsis: Remove temp files.
task clean {
	remove z, README.htm, Release-Notes.htm, PowerShelf.*.nupkg
}

# Synopsis: Copy files to z\tools.
task package markdown, {
	remove z
	$null = mkdir z\tools

	Copy-Item -Destination z\tools @(
		'..\*-*.ps1'
		'..\LICENSE'
		'README.htm'
	)
}

# Synopsis: Set $script:Version.
task version {
	($script:Version = switch -File Release-Notes.md -Regex {'##\s+v(\d+\.\d+\.\d+)' {$Matches[1]; break}})
}

# Synopsis: Push with a version tag.
task pushRelease version, {
	$changes = exec { git status --short }
	assert (!$changes) "Please, commit changes."

	exec { git push }
	exec { git tag -a "v$Version" -m "v$Version" }
	exec { git push origin "v$Version" }
}

# Synopsis: Push NuGet package.
task pushNuGet nuget, {
	$NuGetApiKey = Read-Host NuGetApiKey
	exec { nuget.exe push "PowerShelf.$Version.nupkg" -Source nuget.org -ApiKey $NuGetApiKey }
},
Clean

# Synopsis: Make NuGet package.
task nuget package, version, {
	$description = @'
PowerShell tools for various tasks implemented as scripts, mostly standalone.
'@

	Set-Content z\Package.nuspec @"
<?xml version="1.0"?>
<package xmlns="http://schemas.microsoft.com/packaging/2010/07/nuspec.xsd">
	<metadata>
		<id>PowerShelf</id>
		<version>$Version</version>
		<owners>Roman Kuzmin</owners>
		<authors>Roman Kuzmin</authors>
		<projectUrl>https://github.com/nightroman/PowerShelf</projectUrl>
		<license type="expression">Apache-2.0</license>
		<requireLicenseAcceptance>false</requireLicenseAcceptance>
		<description>$description</description>
		<tags>NuGet PowerShell Debugging Tracing Coverage Tools</tags>
		<developmentDependency>true</developmentDependency>
	</metadata>
</package>
"@

	exec { nuget.exe pack z\Package.nuspec -NoPackageAnalysis }
}
