
<#
.Synopsis
	Syncs two directories with some interaction.
	Author: Roman Kuzmin

.Description
	Requires:
	* Robocopy.exe, Windows utility since Windows Vista
	* .NET Framework v3.5 or above (HashSet is used)
	Optional:
	* %MERGE% - directory comparison tool path

	The script automates one simple scenario. Some directory exists in several
	places (home, work, removable drive, backup copy, etc.) but changes in it
	are normally done in one of them and they should be propagated to another.
	The script visualizes these changes and tries to determine which directory
	is newer and should be mirrored.

	The script compares modification times of files in two directories. If one
	directory is apparently newer than another the script prompts to mirror it
	using Robocopy. Changed files and files from each directory not found in
	another are shown using different colors before the prompt.

	It is possible to skip the suggested operation and tell to mirror in the
	opposite direction or start an external application for visual directory
	comparison.

	The tool is simple but it saves time when such operations are repeatedly
	performed manually. Besides it may help to avoids mistakes and data loss
	(like copying in a wrong direction).

.Parameter Directory1
		Specifies the first directory.
		If it is missing then the second should exist.
.Parameter Directory2
		Specifies the second directory.
		If it is missing then the first should exist.

.Inputs
	None
.Outputs
	None

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
	[Parameter(Mandatory=1)]
	[string]$Directory1,
	[Parameter(Mandatory=1)]
	[string]$Directory2
)
try {&{ # amend errors
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$Directory1 = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($Directory1)
$Directory2 = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($Directory2)

$exist1 = [System.IO.Directory]::Exists($Directory1)
$exist2 = [System.IO.Directory]::Exists($Directory2)

if (!$exist1 -and !$exist2) {
	throw "Directories '$Directory1' and '$Directory2' do not exist."
}

# calls Robocopy.exe
function Invoke-Robocopy($source, $target)
{
	Robocopy.exe $source $target /MIR /FFT /NDL /NJH /NP /NS
	if ($LastExitCode -gt 3) { throw "Robocopy failed." }
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
	Write-Warning "Directory 1 '$Directory1' does not exist."
	if ((Get-Choice "Mirror 2->1 '$Directory2' to '$Directory1'") -eq 0) {
		Invoke-Robocopy $Directory2 $Directory1
	}
	return
}

# no target?
if (!$exist2) {
	Write-Warning "Directory 2 '$Directory2' does not exist."
	if ((Get-Choice "Mirror 1->2 '$Directory1' to '$Directory2'") -eq 0) {
		Invoke-Robocopy $Directory1 $Directory2
	}
	return
}

# get paths
$d1 = [System.Collections.Generic.HashSet[string]]([StringComparer]::OrdinalIgnoreCase)
foreach($_ in Get-ChildItem -LiteralPath $Directory1 -Force -Recurse -Name) {$null = $d1.Add($_)}
$d2 = [System.Collections.Generic.HashSet[string]]([StringComparer]::OrdinalIgnoreCase)
foreach($_ in Get-ChildItem -LiteralPath $Directory2 -Force -Recurse -Name) {$null = $d2.Add($_)}

# except
$o1 = [System.Collections.Generic.HashSet[string]]([StringComparer]::OrdinalIgnoreCase)
$o1.UnionWith($d1)
$o1.ExceptWith($d2)
$o2 = [System.Collections.Generic.HashSet[string]]([StringComparer]::OrdinalIgnoreCase)
$o2.UnionWith($d2)
$o2.ExceptWith($d1)

$RegexHidden = [regex]'\\\.(?:git|svn)'

$o1 | .{process{ if ($_ -notmatch $RegexHidden) {
	Write-Host "$Directory1 extra: $_" -ForegroundColor Green
}}}

$o2 | .{process{ if ($_ -notmatch $RegexHidden) {
	Write-Host "$Directory2 extra: $_" -ForegroundColor Cyan
}}}

$o1 = $o1.Count
$o2 = $o2.Count

# compare
$n1 = 0
$n2 = 0
$nn = 0
$d1.IntersectWith($d2)
foreach($_ in $d1) {
	$i1 = Get-Item -LiteralPath $Directory1\$_ -Force
	$i2 = Get-Item -LiteralPath $Directory2\$_ -Force
	if ($i1.PSIsContainer -ne $i2.PSIsContainer) {
		++$nn
		Write-Warning "Found an item which is a file and a directory: '$_'."
		continue
	}
	if ($i1.PSIsContainer) {
		continue
	}
	$w1 = $i1.LastWriteTime
	$w2 = $i2.LastWriteTime
	$ww = ($w1 - $w2).TotalSeconds
	if ($ww -gt 2) {
		++$n1
		if ($_ -notmatch $RegexHidden) {
			Write-Host "$Directory1 newer: $_" -ForegroundColor Green
		}
	}
	elseif ($ww -lt -2) {
		++$n2
		if ($_ -notmatch $RegexHidden) {
			Write-Host "$Directory2 newer: $_" -ForegroundColor Cyan
		}
	}
}

# no job?
if ($nn + $n1 + $n2 + $o1 + $o2 -eq 0) {
	Write-Host "Same '$Directory1' and '$Directory2'."
	return
}

# summary
'-----'
if ($o1) { Write-Host "$o1 extra in '$Directory1'" -ForegroundColor Green }
if ($n1) { Write-Host "$n1 newer in '$Directory1'" -ForegroundColor Green }
if ($o2) { Write-Host "$o2 extra in '$Directory2'" -ForegroundColor Cyan }
if ($n2) { Write-Host "$n2 newer in '$Directory2'" -ForegroundColor Cyan }

# warnings
if ($nn) { Write-Warning "$nn mismatched" }
if ($n1 -and $n2) { Write-Warning "Both directories are modified." }
if ($o1 -and $o2) { Write-Warning "Both directories have extra items." }

# ask 1->2
if (!$nn -and $n1 -ne 0 -and $n2 -eq 0) {
	if ((Get-Choice "Mirror 1->2 '$Directory1' to '$Directory2'") -eq 0) {
		Invoke-Robocopy $Directory1 $Directory2
		return
	}
}

# ask 2->1
if (!$nn -and $n1 -eq 0 -and $n2 -ne 0) {
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
	1 { Invoke-Robocopy $Directory1 $Directory2 }
	2 { Invoke-Robocopy $Directory2 $Directory1 }
	3 {
		if ($env:MERGE -and (Test-Path -LiteralPath $env:MERGE)) {
			Start-Process $env:MERGE "`"$Directory1`" `"$Directory2`""
		}
		else {
			Write-Warning "%MERGE% is not defined or does not exist."
		}
	}
}

}}
catch {
	Write-Error $_ -ErrorAction Stop
}
