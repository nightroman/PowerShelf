<#PSScriptInfo
.VERSION 1.0.2
.AUTHOR Roman Kuzmin
.COPYRIGHT (c) Roman Kuzmin
.TAGS Git Diff Patch Compare Merge
.GUID 964fe648-2547-4062-a2ce-6a0756b50223
.PROJECTURI https://github.com/nightroman/PowerShelf
.LICENSEURI http://www.apache.org/licenses/LICENSE-2.0
#>

<#
.Synopsis
	Expands git diff into directories "a" and "b".

.Description
	The script is designed for diff and patch files created by git. It expands
	the specified diff file into directories "a" and "b" (original and changes)
	with pieces of files stored in the diff.

	Then you can use your diff tool of choice in order to compare the
	directories "a" and "b", i.e. to visualize the original diff file.

	The following diff lines are recognized and processed:

		--- a/... | "a/..." | /dev/null ~ file "a"
		+++ b/... | "b/..." | /dev/null ~ file "b"
		@@... ~ chunk header
		 ... ~ common line
		-... ~ "a" line
		+... ~ "b" line

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
if (Test-Path -LiteralPath $RootA) {throw "The item '$RootA' exists. Remove it or specify a different root."}
if (Test-Path -LiteralPath $RootB) {throw "The item '$RootB' exists. Remove it or specify a different root."}
$null = [System.IO.Directory]::CreateDirectory($RootA)
$null = [System.IO.Directory]::CreateDirectory($RootB)

$fileA = ''
$fileB = ''
$linesA = [Activator]::CreateInstance([System.Collections.Generic.List[string]])
$linesB = [Activator]::CreateInstance([System.Collections.Generic.List[string]])

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

$regexOctets = [regex]'(\\\d\d\d)+'

$decodeOctets = {
	$x = $args[0].Value
	$n = $x.Length / 4
	$a = [Activator]::CreateInstance([byte[]], $n)
	for($i = 0; $i -lt $n; ++$i) {
		$a[$i] = [Convert]::ToByte($x.Substring($i * 4 + 1, 3), 8)
	}
	[System.Text.Encoding]::UTF8.GetString($a)
}

function Decode-Path($Path) {
	$regexOctets.Replace($Path, $decodeOctets)
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
	elseif ($line -cmatch '^--- (a/.+)(\t|$)') {
		Write-A
		$fileA = $matches[1]
		$null = [System.IO.Directory]::CreateDirectory("$Root/$(Split-Path $fileA)")
	}
	elseif ($line -cmatch '^--- "(a/.+)"') {
		Write-A
		$fileA = Decode-Path ($matches[1])
		$null = [System.IO.Directory]::CreateDirectory("$Root/$(Split-Path $fileA)")
	}
	elseif ($line.StartsWith('--- /dev/null')) {
		Write-A
	}
	elseif ($line -cmatch '^\+\+\+ (b/.+)(\t|$)') {
		Write-B
		$fileB = $matches[1]
		$null = [System.IO.Directory]::CreateDirectory("$Root/$(Split-Path $fileB)")
	}
	elseif ($line -cmatch '^\+\+\+ "(b/.+)"') {
		Write-B
		$fileB = Decode-Path ($matches[1])
		$null = [System.IO.Directory]::CreateDirectory("$Root/$(Split-Path $fileB)")
	}
	elseif ($line.StartsWith('+++ /dev/null')) {
		Write-B
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
