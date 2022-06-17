<#PSScriptInfo
.VERSION 1.0.0
.AUTHOR Roman Kuzmin
.COPYRIGHT (c) Roman Kuzmin
.TAGS Markdown README
.GUID 0ab2bbcb-6552-415f-a102-7799e8a051b8
.LICENSEURI http://www.apache.org/licenses/LICENSE-2.0
.PROJECTURI https://github.com/nightroman/PowerShelf
#>

<#
.Synopsis
	Updates markdown index from article directories.
	Author: Roman Kuzmin

.Description
	The command scans the articles recursively, finds README.md files and
	builds the index from their first line headings in the main README.md.

	The generated list with links is inserted into the specified markdown file.
	The index start and end are defined by the HTML comments Mark1 and Mark2.

.Parameter Path
		Specifies the source markdown file to be updated.
		Default: README.md

.Parameter Articles
		Specifies the directory to scan for folders with README.md files.
		Default: 'Articles'

.Parameter Depth
		Specifies the recursive scan depth.
		Default: 0, non-recursive scan.

.Parameter Descending
		Tells to sort root directories descending.

.Parameter Mark1
		The HTML comment that marks the start of generated index.
		Default: '<!--Generated-->'

.Parameter Mark2
		The HTML comment that marks the end of generated index.
		Default: '<!--Generated-->'

.Link
	https://github.com/nightroman/PowerShelf
#>

[CmdletBinding()]
param(
	[string]$Path = 'README.md'
	,
	[string]$Articles = 'Articles'
	,
	[int]$Depth
	,
	[switch]$Descending
	,
	[string]$Mark1 = '<!--Generated-->'
	,
	[string]$Mark2 = '<!--Generated-->'
)

$ErrorActionPreference = 1
Set-StrictMode -Version 3
trap { Write-Error $_ }

$escape = [regex]@'
[\!\"\#\$\%\&\'\(\)\*\+\,\-\.\/\:\;\<\=\>\?\@\[\\\]\^_\`\{\|\}\~]
'@

# Gets markdown list lines with links for folders recursively.
function Get-List($Path, $Level) {
	$tab = '    ' * $Level

	# get and sort directories
	$items = Get-ChildItem -LiteralPath $Path -Name -Directory
	if ($Level -eq 0) {
		$items = $items | Sort-Object -Descending:$Descending
	}

	foreach($dir in $items) {
		# skip the folder without README
		$readme = "$Path/$dir/README.md"
		if (!(Test-Path -LiteralPath $readme)) {
			continue
		}

		# the first README line must be heading, get the topic text
		switch -File $readme -Regex {
			'^#{1,6}(.*)' {
				$topic = $escape.Replace($matches[1].Trim(), '\$0')
				break
			}
			default {
				throw "Expected first line heading in '$readme'"
			}
		}

		# output the list line with the topic link
		'{0}- [{1}]({2})' -f $tab, $topic, "$Path/$dir"

		# process sub-folders
		if ($Level -lt $Depth) {
			Get-List "$Path/$dir" ($Level + 1)
		}
	}
}

$Path = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($Path)
if (!(Test-Path -LiteralPath $Path)) {
	throw "'$Path' does not exist."
}

# collect lines before and after marks
$lines1 = [System.Collections.Generic.List[string]]@()
$lines2 = [System.Collections.Generic.List[string]]@()
$step = 1
foreach($_ in Get-Content -LiteralPath $Path) {
	if ($step -eq 1) {
		$lines1.Add($_)
		if ($_ -eq $Mark1) {
			++$step
		}
		continue
	}

	if ($step -eq 2) {
		if ($_ -eq $Mark2) {
			$lines2.Add($_)
			++$step
		}
		continue
	}

	$lines2.Add($_)
}

if ($step -ne 3) {
	throw "Cannot find mark '$Mark1' or '$Mark2' in '$Path'."
}

# update source file
$(
	$lines1
	Get-List $Articles 0
	$lines2
) | Set-Content -LiteralPath $Path -Encoding UTF8
