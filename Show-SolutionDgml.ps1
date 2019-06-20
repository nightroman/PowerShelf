
<#PSScriptInfo
.VERSION 1.1.1
.AUTHOR Roman Kuzmin
.COPYRIGHT (c) Roman Kuzmin
.TAGS DGML, solution, project, graph
.GUID 5a3b9854-4349-43e6-93f0-599e608ba81c
.LICENSEURI http://www.apache.org/licenses/LICENSE-2.0
.PROJECTURI https://github.com/nightroman/PowerShelf
#>

<#
.Synopsis
	Generates and shows the solution project graph.

.Description
	For the given solution, the script generates project graph with project
	reference links defined in project files and build order links defined
	in the solution. Then the generated DGML is opened by the associated
	program, normally Visual Studio.

	For viewing in Visual Studio ensure:
	- Individual components \ Code tools \ DGML editor

.Parameter SolutionPath
		Specifies the solution path. If it is omitted or empty then the *.sln
		file in the current location is used, there must be one such file.

.Parameter Exclude
		Specifies the projects to exclude. Wilcards are supported.
		The patterns should match project names without extensions.

.Parameter JustProject
		Tells to show just references defined in project files and ignore build
		order dependencies in the solution.

.Parameter JustSolution
		Tells to show just build order dependencies defined in the solution and
		ignore references in project files.

.Link
	https://github.com/nightroman/PowerShelf
#>

[CmdletBinding()]
param(
	[string]$SolutionPath,
	[string[]]$Exclude,
	[switch]$JustProject,
	[switch]$JustSolution
)

trap {$PSCmdlet.ThrowTerminatingError($_)}
Set-StrictMode -Version Latest
$ErrorActionPreference = 1

# resolve the solution path
if ($SolutionPath) {
	$SolutionPath = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($SolutionPath)
	if (![System.IO.File]::Exists($SolutionPath)) {throw "Missing file '$SolutionPath'."}
}
else {
	$items = @(Get-Item *.sln)
	if ($items.Count -eq 1) {
		$SolutionPath = $items[0].FullName
	}
	elseif (!$items) {
		throw 'Cannot find a solution file in the current location.'
	}
	else {
		throw 'Too many solution files in the current location.'
	}
}

# read the solution
$solutionText = [System.IO.File]::ReadAllText($SolutionPath)

$Output = "$env:TEMP\$([System.IO.Path]::GetFileNameWithoutExtension($SolutionPath)).dgml"
$RootPath = Split-Path $SolutionPath

$ccprojType = '{CC5FD16D-436D-48AD-A40C-5A424C6E3E79}'
$csprojType = '{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}'
$csprojTypeSdk = '{9A19103F-16F7-4668-BE54-9A1E7A4F7556}'
$folderType = '{2150E333-8FDC-42A3-9474-1A3956D46DE8}'
$fsprojType = '{F2A71F9B-5D33-465A-A702-920D77279786}'
$fsprojTypeSdk = '{6EC3EE1D-3C4E-46DD-8F32-0CC8E7565705}'
$sfprojType = '{A07B5EB6-E848-4116-A8D0-A826331D98C6}'
$vcxprojType = '{8BC9CEB8-8B4A-11D0-8D11-00A0C91BC942}'
function Get-ProjectCategory($Project) {
	switch($Project.type) {
		$ccprojType {return 'CloudService'}
		$csprojType {return 'CSharp'}
		$csprojTypeSdk {return 'CSharp.Sdk'}
		$folderType {return 'Folder'}
		$fsprojType {return 'FSharp'}
		$fsprojTypeSdk {return 'FSharp.Sdk'}
		$sfprojType {return 'ServiceFabric'}
		$vcxprojType {return 'CPlusPlusCLI'}
		default {return $_}
	}
}

$reMatchProject = [regex]'(?msx)^\s* Project \b (.+?) \b ^\s* EndProject \s*$'

$reParseProject = [regex]@'
(?sx)
^\s* \(" ({[^}]+}) "\)
\s* = \s* " ([^"]+) " \s*,
\s* " ([^"]+) " \s*,
\s* " ({[^}]+}) "
\s* (.*)
'@

$reMatchProjectDependencies = [regex]@'
(?sx)
\b ProjectSection \s* \( \s* ProjectDependencies \s* \) \s* = \s* postProject \s*
(.*?)
EndProjectSection
'@

$reMatchProjectDependency = [regex]'(?mx) ^\s* ({[^}]+}) .*$'

$map = @{}
$projectMatches = $reMatchProject.Matches($solutionText)
foreach($match in $projectMatches) {
	$text = $match.Groups[1].Value

	# parse project text
	if ($text -notmatch $reParseProject) {throw "Cannot parse project text: $text"}
	$project = [PSCustomObject]@{
		# project type GUID
		type = $Matches[1]

		# name, file base name
		name = $Matches[2]

		# path, normally relative
		path = $Matches[3]

		# GUID from the solution
		id = $Matches[4]

		# project text
		body = $Matches[5]
	}

	# skip folders, for now
	if ($project.type -eq $folderType) {continue}

	# add project
	$map.Add($project.id, $project)
}

$xml = [xml]@'
<?xml version="1.0" encoding="utf-8"?>
<DirectedGraph GraphDirection="TopToBottom" Layout="Sugiyama">
	<Styles>
		<Style TargetType="Link">
			<Condition Expression="HasCategory('SolutionLink')" />
			<Setter Property="StrokeDashArray" Value="3 3" />
		</Style>
	</Styles>
</DirectedGraph>
'@
$doc = $xml.DocumentElement
$nodes = $doc.AppendChild($xml.CreateElement('Nodes'))
$links = $doc.AppendChild($xml.CreateElement('Links'))

$ns = @{x = 'http://schemas.microsoft.com/developer/msbuild/2003'}

function Test-Exclude($Name) {
	foreach($_ in $Exclude) {
		if ($Name -like $_) {return $true}
	}
}

foreach($project in $map.Values) {
	if (Test-Exclude ($project.name)) {continue}

	$node = $nodes.AppendChild($xml.CreateElement('Node'))
	$node.SetAttribute('Id', $project.name)
	$node.SetAttribute('Path', $project.path)
	$node.SetAttribute('Category', (Get-ProjectCategory $project))

	### links from solution
	if (!$JustProject -and $project.body -and $project.body -match $reMatchProjectDependencies) {
		foreach($match in $reMatchProjectDependency.Matches($Matches[1])) {
			$id = $match.Groups[1].Value
			$project2 = $map[$id]
			if (Test-Exclude ($project2.name)) {continue}

			$link = $links.AppendChild($xml.CreateElement('Link'))
			$link.SetAttribute('Source', $project.name)
			$link.SetAttribute('Target', $project2.name)
			$link.SetAttribute('Category', 'SolutionLink')
		}
	}

	### links from project
	if (!$JustSolution) {
		# project full path
		$projectPath = $project.path
		if (![System.IO.Path]::IsPathRooted($projectPath)) {
			$projectPath = Join-Path $RootPath $projectPath
		}

		# read project XML
		$xml2 = [xml](Get-Content -LiteralPath $projectPath)

		# query project references
		if ($xml2.DocumentElement.GetAttribute('Sdk') -eq 'Microsoft.NET.Sdk') {
			$references = $xml2 | Select-Xml //ProjectReference/@Include
		}
		else {
			$references = $xml2 | Select-Xml //x:ProjectReference/@Include -Namespace $ns
		}

		# write project links
		foreach ($reference in $references) {
			$name2 = [System.IO.Path]::GetFileName($reference.Node.'#text')

			$project2 = @(
				foreach($_ in $map.Values) {
					if ([System.IO.Path]::GetFileName($_.path) -eq $name2) {
						$_
					}
				}
			)

			# When a project is removed from a solution its references are not
			# removed from unloaded projects, so missing links are possible.
			if ($project2.Count -eq 0) {
				Write-Warning "Cannot find '$name2' referenced by '$projectPath' in the solution."
				continue
			}

			# In theory, we may have several projects with the same name but
			# with different extension of path. This is weird, fail for now.
			if ($project2.Count -ge 2) {throw "Too many '$name2' in the solution."}

			if (Test-Exclude ($project2[0].name)) {continue}

			$link = $links.AppendChild($xml.CreateElement('Link'))
			$link.SetAttribute('Source', $project.name)
			$link.SetAttribute('Target', $project2[0].name)
			$link.SetAttribute('Category', 'ProjectLink')
		}
	}
}

# finish, save, and open the graph
$doc.SetAttribute('xmlns', 'http://schemas.microsoft.com/vs/2009/dgml')
$xml.Save($Output)
Invoke-Item $Output
