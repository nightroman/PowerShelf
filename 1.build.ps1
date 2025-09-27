<#
.Synopsis
	Build script, https://github.com/nightroman/Invoke-Build
#>

Set-StrictMode -Version 3

# Synopsis: Remove temp files.
task clean {
	remove z, README.html, *.nupkg
}

# Synopsis: Convert markdown to HTML.
task markdown {
	exec { pandoc.exe --standalone --from=gfm --output=README.html README.md --metadata=pagetitle=README }
}

# Synopsis: Set $script:Version.
task version {
	($script:Version = switch -File Release-Notes.md -Regex {'##\s+v(\d+\.\d+\.\d+)' {$Matches[1]; break}})
}

# Synopsis: Push with a version tag.
task pushRelease version, {
	assert (!(exec { git status --short })) "Commit changes."
	exec { git push }
	exec { git tag -a "v$Version" -m "v$Version" }
	exec { git push origin "v$Version" }
}

# Synopsis: Push NuGet package.
task pushNuGet nuget, {
	$NuGetApiKey = Read-Host NuGetApiKey
	exec { nuget.exe push "PowerShelf.$Version.nupkg" -Source nuget.org -ApiKey $NuGetApiKey }
},
clean

# Synopsis: Copy files to z\tools.
task package markdown, {
	remove z
	$null = mkdir z\tools

	Copy-Item -Destination z @(
		'README.md'
	)

	Copy-Item -Destination z\tools @(
		'*-*.ps1'
		'LICENSE'
		'README.html'
	)
}

# Synopsis: Make NuGet package.
task nuget package, version, {
	Set-Content z\Package.nuspec @"
<?xml version="1.0"?>
<package xmlns="http://schemas.microsoft.com/packaging/2010/07/nuspec.xsd">
	<metadata>
		<id>PowerShelf</id>
		<version>$Version</version>
		<authors>Roman Kuzmin</authors>
		<owners>Roman Kuzmin</owners>
		<developmentDependency>true</developmentDependency>
		<license type="expression">Apache-2.0</license>
		<readme>README.md</readme>
		<projectUrl>https://github.com/nightroman/PowerShelf</projectUrl>
		<description>PowerShell tools for various tasks implemented as scripts, mostly standalone.</description>
		<releaseNotes>https://github.com/nightroman/PowerShelf/blob/main/Release-Notes.md</releaseNotes>
		<tags>NuGet PowerShell Debugging Tracing Coverage Tools</tags>
	</metadata>
</package>
"@

	exec { nuget.exe pack z\Package.nuspec -NoPackageAnalysis }
}

task docs {
	$text = $(
		'# PowerShelf Scripts'
		''
		foreach($item in Get-ChildItem *-*.ps1) {
			$name = $item.Name
			Convert-HelpToDocs.ps1 $item "docs/$name.md"

			$r = Get-Help $name
			"- [$name]($name.md) - $(@($r.Synopsis -split '\r?\n')[0])"
		}
	) -join "`n"
	Set-Content docs/README.md $text
}

# Synopsis: Release changes.
task release pushNuGet, pushRelease -If {
	Assert-GitBranchClean.ps1
	$true
}
