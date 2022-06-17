<#PSScriptInfo
.VERSION 1.0.1
.AUTHOR Roman Kuzmin
.COPYRIGHT (c) Roman Kuzmin
.TAGS Markdown README Index TOC
.GUID 0ab2bbcb-6552-415f-a102-7799e8a051b8
.LICENSEURI http://www.apache.org/licenses/LICENSE-2.0
.PROJECTURI https://github.com/nightroman/PowerShelf
#>

<#
.Synopsis
	Updates README index from content directories.
	Author: Roman Kuzmin

.Description
	The command scans the contents recursively, finds README.md files and
	builds the index from their first line headings in the root README.md.

	The generated list with links is inserted into the root README.md.
	The index start/end marks are defined by the HTML comments like:
	given $Content='docs', marks are '<!--docs-->'.

.Parameter Content
		Specifies the directory to scan with the path relative to root.
		Use '/' as directory separators if it is not the top directory.

.Parameter Root
		Specifies the root directory with README.md to be updated.
		The typical use case is a git repository root.
		Default: the current location

.Parameter Depth
		Specifies the recursive scan depth.
		Default: 0, just top directories.

.Parameter Descending
		Tells to sort top directories descending.

.Parameter NoWarning
		Tells not to write warnings about no README.

.Parameter Skip
		The script returning true for the directories to skip.
		Argument 1: directory path like $Content[/dir1[/...]]

.Link
	Example: https://github.com/nightroman/PowerShellTraps

.Link
	https://github.com/nightroman/PowerShelf
#>

[CmdletBinding()]
param(
	[Parameter(Position=0, Mandatory=1)]
	[string]$Content
	,
	[string]$Root = '.'
	,
	[int]$Depth
	,
	[switch]$Descending
	,
	[switch]$NoWarning
	,
	[scriptblock]$Skip
)

$ErrorActionPreference = 1
trap { Write-Error $_ }

# Gets markdown list lines with links to folders recursively.
function Get-List($Path, $Level) {
	$indent = '    ' * $Level

	# get and sort (top) directory names
	$dirNames = Get-ChildItem -LiteralPath $Path -Name -Directory
	if ($Level -eq 0) {
		$dirNames = $dirNames | Sort-Object -Descending:$Descending
	}

	foreach($dirName in $dirNames) {
		$dirPath = "$Path/$dirName"
		if ($Skip -and (& $Skip $dirPath)) {
			continue
		}

		$README = "$dirPath/README.md"

		# case: no README
		if (!(Test-Path -LiteralPath $README)) {
			if ($Level -lt $Depth -and (Get-ChildItem -LiteralPath $dirPath -Recurse -Filter README.md)) {
				# output the list line with the folder name
				'{0}- {1}' -f $indent, $dirName

				# process sub-folders
				Get-List $dirPath ($Level + 1)
			}
			elseif (!$NoWarning) {
				Write-Warning "Found no README in '$dirPath'."
			}
			continue
		}

		# the first README line is heading, get the topic text
		switch -File $README -Regex {
			'^#{1,6}(.*)' {
				$topic = $matches[1].Trim()
				break
			}
			default {
				throw "Expected first line heading in '$README'."
			}
		}

		# output the list line with the topic link
		'{0}- [{1}]({2})' -f $indent, $topic, $dirPath

		# process sub-folders
		if ($Level -lt $Depth) {
			Get-List $dirPath ($Level + 1)
		}
	}
}

### main

$Root = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($Root)
if (!(Test-Path -LiteralPath $Root)) {
	throw "Cannot find '$Root'."
}

$README = "$Root/README.md"
if (!(Test-Path -LiteralPath $README)) {
	throw "Cannot find '$README'."
}

$Mark = "<!--$Content-->"

### collect lines before and after marks
$lines1 = [System.Collections.Generic.List[string]]@()
$lines2 = [System.Collections.Generic.List[string]]@()
$step = 1
foreach($_ in Get-Content -LiteralPath $README) {
	if ($step -eq 1) {
		$lines1.Add($_)
		if ($_ -eq $Mark) {
			++$step
		}
		continue
	}

	if ($step -eq 2) {
		if ($_ -eq $Mark) {
			$lines2.Add($_)
			++$step
		}
		continue
	}

	$lines2.Add($_)
}

if ($step -ne 3) {
	throw "Cannot find two marks '$Mark' in '$README'."
}

### update README
$(
	Push-Location -LiteralPath $Root
	try {
		$lines1
		Get-List $Content 0
		$lines2
	}
	finally {
		Pop-Location
	}
) | Set-Content -LiteralPath $README -Encoding UTF8
