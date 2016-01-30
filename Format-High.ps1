
<#
.Synopsis
	Formats output by columns with optional custom item colors.
	Author: Roman Kuzmin

.Description
	The script prints the property, expression, or input objects by columns and
	determines a suitable column number automatically. As a result, it produces
	quite compact output. Output width and custom item colors can be specified.

	The script is named in contrast to Format-Wide which prints items by rows.

.Parameter Property
		Specifies the property name or a script block operating on $_.
		If it is omitted then object string representations are shown.
.Parameter Width
		The table widths. By default it is the window width minus 1.
.Parameter Color
		An optional scriptblock which for input objects $_ outputs hashtables
		@{ForegroundColor=...; BackgroundColor=...}. Keys can be shortened and
		omitted, e.g. this is valid: @{f='red'}.
.Parameter InputObject
		Input objects as an argument or piped.

.Inputs
	Objects to be shown.
.Outputs
	None. Data are shown by Write-Host.

.Example
	>
	# file system items
	Get-ChildItem $home | Format-High

	# verb names, custom width
	Get-Verb | Format-High Verb 80

	# custom expression and width
	Get-Process | Format-High {$_.Name + ':' + $_.WS} 80

	# process names with colors based on working sets
	Get-Process | Format-High Name 80 {@{f=if($_.WS -gt 10mb){'red'}else{'green'}}}

.Link
	https://github.com/nightroman/PowerShelf
#>

param(
	[Parameter()]
	[object]$Property,
	[int]$Width,
	[scriptblock]$Color,
	[Parameter(ValueFromPipeline=1)]
	[object[]]$InputObject
)

trap {$PSCmdlet.ThrowTerminatingError($_)}

${private:-Property} = $Property
${private:-Width} = $Width
${private:-Color} = $Color
${private:-InputObject} = if ($MyInvocation.ExpectingInput) {@($input)} else {$InputObject}
Remove-Variable Property, Width, Color, InputObject

# input to strings
try {
	$private:strings = if (${-Property} -is [string]) {
		${-InputObject} | Select-Object -ExpandProperty ${-Property}
	}
	elseif (${-Property} -is [scriptblock]) {
		${-InputObject} | ForEach-Object ${-Property}
	}
	else {
		${-InputObject}
	}
	$strings = @(foreach($_ in $strings) { "$_" })
}
catch {
	throw "Error on Property evaluation: $_"
}

# get colors
try {
	$colors = @(if (${-Color}) { ${-InputObject} | ForEach-Object ${-Color} })
}
catch {
	throw "Error on Color evaluation: $_"
}

if (!${-Width}) {
	${-Width} = if (!$Host.UI -or !$Host.UI.RawUI -or !$Host.UI.RawUI.WindowSize) {
		80
	}
	else {
		$Host.UI.RawUI.WindowSize.Width - 1
	}
}

# pass 1: find the maximum column count
$nBest = 1
$bestWidths = @(${-Width})
for($nColumn = 2; ; ++$nColumn) {
	$nRow = [Math]::Ceiling($strings.Count / $nColumn)
	$widths = @(
		for($s = 0; $s -lt $strings.Count; $s += $nRow) {
			$e = [Math]::Min($strings.Count, $s + $nRow)
			($strings[$s .. ($e - 1)] | Measure-Object -Maximum Length).Maximum + 1
		}
	)
	if (($widths | Measure-Object -Sum).Sum -gt ${-Width}) { break }
	$bestWidths = $widths
	$nBest = $nColumn
	if ($nRow -le 1) { break }
}

# pass 2: print strings
$nRow = [Math]::Ceiling($strings.Count / $nBest)
for($r = 0; $r -lt $nRow; ++$r) {
	for($c = 0; $c -lt $nBest; ++$c) {
		$i = $c * $nRow + $r
		if ($i -lt $strings.Count) {
			$t = $strings[$i].PadRight($bestWidths[$c])
			if ($colors) {
				$p = $colors[$i]
				Write-Host $t -NoNewline @p
			}
			else {
				Write-Host $t -NoNewline
			}
		}
	}
	Write-Host ''
}
