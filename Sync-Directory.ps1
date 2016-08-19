
<#
.Synopsis
	Syncs two directories with some interaction.
	Author: Roman Kuzmin

.Description
	Requires:
		Robocopy.exe, Windows utility since Windows Vista
		PowerShell host supporting Write-Host with colors
	Optional:
		%MERGE%, directory comparison application

	The script automates one simple scenario. Some directory exists in several
	places (home, work, removable drive, backup copy, etc.) but changes in it
	are normally done in one of them and they should be propagated to another.
	The script visualizes these changes and tries to determine which directory
	is newer and should be mirrored.

	It is possible to skip the suggested operation and tell to mirror in the
	opposite direction or start an external directory comparison application.

	The tool is simple but it saves time when such operations are repeatedly
	performed manually. Besides it may help to avoids mistakes and data loss
	(like copying in a wrong direction).

.Parameter Directory1
		Specifies the first directory.
		If it is missing then the second should exist.
.Parameter Directory2
		Specifies the second directory.
		If it is missing then the first should exist.
.Parameter Arguments
		Additional Robocopy arguments. Example:
		... -Arguments /XD, bin, obj, /XF *.tmp, *.bak

.Example
	>
	Lets $env:pc_master and $env:pc_slave are names of two machines. Then this
	code syncs the current directory on the current machine and the directory
	with the same path on another machine:

	$that = if ($env:COMPUTERNAME -eq $env:pc_master) {$env:pc_slave} else {$env:pc_master}
	$dir1 = "$pwd"
	$dir2 = "\\$that\$($dir1 -replace '^(.):', '$1$')"
	Sync-Directory $dir1 $dir2

.Link
	https://github.com/nightroman/PowerShelf
#>

param(
	[Parameter(Position=1, Mandatory=1)]
	[string]$Directory1,
	[Parameter(Position=2, Mandatory=1)]
	[string]$Directory2,
	[string[]]$Arguments
)

trap {$PSCmdlet.ThrowTerminatingError($_)}
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$Directory1 = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($Directory1)
$Directory2 = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($Directory2)
Write-Host "Directory1: $Directory1"
Write-Host "Directory2: $Directory2"

$exist1 = [System.IO.Directory]::Exists($Directory1)
$exist2 = [System.IO.Directory]::Exists($Directory2)

if (!$exist1 -and !$exist2) {
	throw "Directories '$Directory1' and '$Directory2' do not exist."
}

# calls Robocopy.exe
function Invoke-Robocopy($source, $target) {
	$param = $source, $target, '/MIR', '/FFT', '/NDL', '/NP', '/NS'
	if ($Arguments) {$param += $Arguments}
	Robocopy.exe $param
	if ($LastExitCode -gt 3) {throw 'Robocopy failed.'}
}

# asks for a choice
function Get-Choice(
	[string]
	$Caption = 'Confirm',
	[string]
	$Message = 'Are you sure you want to continue?',
	[string[]]
	$Choices = ('&Yes', 'Continue', '&No', 'Skip this'),
	[int]
	$DefaultChoice = 0
)
{
	$descriptions = @()
	for($i = 0; $i -lt $Choices.Count; $i += 2) {
		$c = [System.Management.Automation.Host.ChoiceDescription]$Choices[$i]
		$c.HelpMessage = $Choices[$i + 1]
		$descriptions += $c
	}
	$Host.UI.PromptForChoice($Caption, $Message, [System.Management.Automation.Host.ChoiceDescription[]]$descriptions, $DefaultChoice)
}

# no source?
if (!$exist1) {
	Write-Warning "Directory1 '$Directory1' does not exist."
	if ((Get-Choice "Mirror 2->1 '$Directory2' to '$Directory1'") -eq 0) {
		Invoke-Robocopy $Directory2 $Directory1
	}
	return
}

# no target?
if (!$exist2) {
	Write-Warning "Directory2 '$Directory2' does not exist."
	if ((Get-Choice "Mirror 1->2 '$Directory1' to '$Directory2'") -eq 0) {
		Invoke-Robocopy $Directory1 $Directory2
	}
	return
}

function Write-Info($Info, $Color) {
	Write-Host $Info -ForegroundColor $Color
}

### get file info
$newer1, $newer2, $extra1, $extra2, $others = 0
$param = $Directory1, $Directory2, '/L', '/MIR', '/FFT', '/NDL', '/NP', '/NS', '/NJH', '/NJS'
if ($Arguments) {$param += $Arguments}
switch -regex (Robocopy.exe $param) {
	'^\s+Newer' {
		Write-Info $_ Green
		++$newer1
		continue
	}
	'^\s+Older' {
		Write-Info $_ Cyan
		++$newer2
		continue
	}
	'^\s+New file' {
		Write-Info $_ DarkGreen
		++$extra1
		continue
	}
	'^\s+\*EXTRA File' {
		Write-Info $_ DarkCyan
		++$extra2
		continue
	}
	'^\s*$|^\s*\*EXTRA Dir' {
		continue
	}
	default {
		Write-Info $_ Yellow
		++$others
	}
}
if ($LastExitCode -gt 3) {throw 'Robocopy failed.'}

# no job?
if ($newer1 + $newer2 + $extra1 + $extra2 + $others -eq 0) {
	Write-Host 'Directories are synchronized.'
	return
}

# summary
Write-Host ''
if ($newer1) {Write-Host "$newer1 newer in '$Directory1'" -ForegroundColor Green}
if ($newer2) {Write-Host "$newer2 newer in '$Directory2'" -ForegroundColor Cyan}
if ($extra1) {Write-Host "$extra1 extra in '$Directory1'" -ForegroundColor DarkGreen}
if ($extra2) {Write-Host "$extra2 extra in '$Directory2'" -ForegroundColor DarkCyan}

# warnings
if ($others) {Write-Warning "$others mismatched"}
if ($newer1 -and $newer2) {Write-Warning "Both directories have newer files."}

# ask 1->2
if (!$others -and $newer1 -and !$newer2) {
	if ((Get-Choice "Mirror 1->2 '$Directory1' to '$Directory2'") -eq 0) {
		Invoke-Robocopy $Directory1 $Directory2
		return
	}
}

# ask 2->1
if (!$others -and !$newer1 -and $newer2) {
	if ((Get-Choice "Mirror 2->1 '$Directory2' to '$Directory1'") -eq 0) {
		Invoke-Robocopy $Directory2 $Directory1
		return
	}
}

# more choices
switch(Get-Choice Choose 'What would you like to do?' @(
	'Skip', '',
	'&1->2', "Mirror '$Directory1' to '$Directory2'",
	'&2->1', "Mirror '$Directory2' to '$Directory1'",
	'&Merge', "Start %MERGE%"
)) {
	1 {
		Invoke-Robocopy $Directory1 $Directory2
	}
	2 {
		Invoke-Robocopy $Directory2 $Directory1
	}
	3 {
		if ($env:MERGE -and (Test-Path -LiteralPath $env:MERGE)) {
			Start-Process $env:MERGE "`"$Directory1`" `"$Directory2`""
		}
		else {
			Write-Warning "%MERGE% is not defined or does not exist."
		}
	}
}
