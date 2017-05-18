
<#PSScriptInfo
.VERSION 1.0.0
.AUTHOR Roman Kuzmin
.COPYRIGHT (c) Roman Kuzmin
.TAGS Test
.GUID 1707aec3-6f77-41bd-8df4-953c7704f4a6
.LICENSEURI http://www.apache.org/licenses/LICENSE-2.0
.PROJECTURI https://github.com/nightroman/PowerShelf
#>

<#
.Synopsis
	Compares the sample and result files.

.Description
	This script automates one typical test scenario, it compares the sample and
	result files and performs copy and view operations if the sample is missing
	(nor yet created) or the result is different (potentially valid but changed
	so that the sample may have to be updated after review).

	If the result is missing then the test fails. If the sample is missing then
	a warning is written and the sample is created as a copy of the result. The
	target directory is also created if it does not exist.

	If files are different then the test either fails or, if View is specified,
	writes a warning, invokes View, and then prompts to update the sample.

	File comparison is done via MD5 hashes, it is fast and suitable for large
	files. But there is a tiny chance that file differences are not detected.

.Parameter Sample
		Specifies the sample file path. If it does not exist then it is
		created as a copy of the result.
.Parameter Result
		Specifies the result file path. The file must exist.
.Parameter View
		Specifies a command invoked when the files are different. It is an
		application name or a script block. The arguments are file paths.

.Example
	Assert-SameFile Sample.log Result.log Merge.exe

	This command compares Sample.log and Result.log at the current location and
	uses Merge.exe for viewing differences (Merge.exe and file paths are passed
	in Start-Process).

.Example
	Assert-SameFile Sample.log Result.log {git diff --no-index $args[0] $args[1]}

	This command uses git in order to view changes. git requires more arguments
	than Merge.exe above, so that the proper script block is used as a command.

.Link
	https://github.com/nightroman/PowerShelf
#>

param(
	[Parameter(Mandatory=1)]
	[string]$Sample,
	[Parameter(Mandatory=1)]
	[string]$Result,
	$View
)

$ErrorActionPreference = 'Stop'

# result must exist
$fileResult = [System.IO.FileInfo]$PSCmdlet.GetUnresolvedProviderPathFromPSPath($Result)
if (!$fileResult.Exists) {
	Write-Error "Missing result file '$Result'."
}

# make missing sample
$fileSample = [System.IO.FileInfo]$PSCmdlet.GetUnresolvedProviderPathFromPSPath($Sample)
if (!$fileSample.Exists) {
	$null = [System.IO.Directory]::CreateDirectory($fileSample.DirectoryName)
	Copy-Item -LiteralPath $fileResult.FullName -Destination $fileSample.FullName -Force
	Write-Warning "Created missing sample file '$Sample'."
	return
}

# compare
$same = $fileResult.Length -eq $fileSample.Length
if ($same) {
	$md5 = [System.Security.Cryptography.MD5]::Create()
	$reader = $fileSample.OpenRead()
	try {
		$1 = [Guid]$md5.ComputeHash($reader)
		$reader.Close()
		$2 = [Guid]$md5.ComputeHash(($reader = $fileResult.OpenRead()))
		$same = $1 -eq $2
	}
	finally {
		$reader.Close()
	}
}

# pass
if ($same) {
	return
}

# abort
if (!$View) {
	Write-Error "Different sample '$Sample' and result '$Result'."
}

Write-Warning "Different sample '$Sample' and result '$Result'."

# start view
if ($View -is [scriptblock]) {
	& $View $fileSample.FullName $fileResult.FullName
}
elseif ($View -is [string]) {
	Start-Process $View $fileSample.FullName, $fileResult.FullName
}
else {
	Write-Error "Invalid view command: '$View'."
}

# choice, cast is for v2.0
function Get-Choice($Caption, $Message, $Choices) {
	$Host.UI.PromptForChoice($Caption, $Message, [System.Management.Automation.Host.ChoiceDescription[]]$Choices, 0)
}
function New-Choice {
	New-Object System.Management.Automation.Host.ChoiceDescription $args
}

# prompt
switch(Get-Choice 'Different result' 'How would you like to proceed?' @(
		New-Choice '&0. Ignore' 'Do nothing.'
		New-Choice '&1. Update' 'Copy result to sample.'
		New-Choice '&2. Abort' 'Write terminating error.'
	))
{
	1 {
		Copy-Item -LiteralPath $fileResult.FullName -Destination $fileSample.FullName -Force
	}
	2 {
		Write-Error "Different sample '$Sample' and result '$Result'."
	}
}
