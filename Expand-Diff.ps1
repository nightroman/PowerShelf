<#PSScriptInfo
.VERSION 1.0.0
.AUTHOR Roman Kuzmin
.COPYRIGHT (c) Roman Kuzmin
.TAGS Git Diff Compare Merge
.GUID 964fe648-2547-4062-a2ce-6a0756b50223
.PROJECTURI https://github.com/nightroman/PowerShelf
.LICENSEURI http://www.apache.org/licenses/LICENSE-2.0
#>

<#
.Synopsis
	Expands the diff into directories "a" and "b".

.Description
	The script is designed for diff and patch files created by git. It expands
	the specified diff file into directories "a" and "b" (original and changes)
	with pieces of files provided by the diff.

	Then you can use your diff tool of choice in order to compare the
	directories "a" and "b", i.e. to visualize the original diff file.

	Diff file lines are processed as:

		--- /dev/null - "a" is missing
		+++ /dev/null - "b" is missing
		--- a/...     - "a" file path
		+++ b/...     - "b" file path
		@@...         - chunk header
		 ...          - common line
		-...          - "a" line
		+...          - "b" line

	Other lines are ignored.

.Parameter Diff
		Specifies the diff file path.

.Parameter Root
		Specifies the output directory where the directories "a" and "b" will
		be created. The script fails if "a" or "b" exists in this directory.
		If this parameter is omitted then the current location is used.

.Link
	https://github.com/nightroman/PowerShelf
#>

[CmdletBinding()]
param(
	[Parameter(Mandatory=1)]
	[string]$Diff,
	[string]$Root = '.'
)

trap {$PSCmdlet.ThrowTerminatingError($_)}
$ErrorActionPreference = 1

$Diff = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($Diff)
$Root = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($Root)

$RootA = Join-Path $Root a
$RootB = Join-Path $Root b
if (Test-Path -LiteralPath $RootA) {throw "The path '$RootA' exists. Remove it or specify a different root."}
if (Test-Path -LiteralPath $RootB) {throw "The path '$RootB' exists. Remove it or specify a different root."}
$null = [System.IO.Directory]::CreateDirectory($RootA)
$null = [System.IO.Directory]::CreateDirectory($RootB)

$fileA = ''
$fileB = ''
$linesA = [System.Collections.Generic.List[string]]@()
$linesB = [System.Collections.Generic.List[string]]@()

function Write-A {
	if ($fileA) {
		[System.IO.File]::WriteAllLines("$Root/$fileA", $linesA)
		$script:fileA = ''
		$linesA.Clear()
	}
}

function Write-B {
	if ($fileB) {
		[System.IO.File]::WriteAllLines("$Root/$fileB", $linesB)
		$script:fileB = ''
		$linesB.Clear()
	}
}

foreach($line in Get-Content -LiteralPath $Diff -Encoding UTF8) {
	if ($line.StartsWith('@@')) {
		if ($fileA -and $fileB) {
			if ($linesA) {$linesA.Add('')}
			if ($linesB) {$linesB.Add('')}
			$linesA.Add($line)
			$linesB.Add($line)
		}
	}
	elseif ($line.StartsWith('---')) {
		Write-A
		if ($line.StartsWith('--- a/')) {
			$fileA = $line.Substring(4)
			$null = [System.IO.Directory]::CreateDirectory("$Root/$(Split-Path $fileA)")
		}
		elseif ($line -cne '--- /dev/null') {
			throw "Unknown line: $line"
		}
	}
	elseif ($line.StartsWith('+++')) {
		Write-B
		if ($line.StartsWith('+++ b/')) {
			$fileB = $line.Substring(4)
			$null = [System.IO.Directory]::CreateDirectory("$Root/$(Split-Path $fileB)")
		}
		elseif ($line -cne '+++ /dev/null') {
			throw "Unknown line: $line"
		}
	}
	elseif ($line.StartsWith(' ')) {
		$text = $line.Substring(1)
		$linesA.Add($text)
		$linesB.Add($text)
	}
	elseif ($line.StartsWith('-')) {
		$linesA.Add($line.Substring(1))
	}
	elseif ($line.StartsWith('+')) {
		$linesB.Add($line.Substring(1))
	}
}

Write-A
Write-B
