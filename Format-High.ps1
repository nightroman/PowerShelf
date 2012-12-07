
<#
.Synopsis
	Formats output by columns with optional custom item colors.
	Author: Roman Kuzmin

.Description
	The script prints the specified property, expression, or input objects by
	columns. Custom item colors can be calculated by the scriptblock Color.

	The script is named in contrast to Format-Wide which prints items by rows.

.Parameter Property
		Specifies the name of object property that appears in the table. If it
		is omitted then object string representations are shown. It also can be
		a scriptblock which for input objects $_ outputs values to be shown.
.Parameter Width
		The table widths. By default it is the window width minus 1.
.Parameter Color
		An optional scriptblock which for input objects $_ outputs hashtables
		@{ForegroundColor=...; BackgroundColor=...}. Keys can be shortened and
		omitted, e.g. this is valid: @{f='red'}.
.Parameter InputObject
		Input objects. Default are from the pipeline.

.Inputs
	Objects to be shown. Alternatively, use the parameter InputObject.
.Outputs
	None. Data are written to the screen by Write-Host.

.Example
	#
	# file system items
	ls $home | Format-High

	# processes, not good
	ps | Format-High

	# process names, good
	ps | Format-High Name

	# custom expression and width
	ps | Format-High {$_.Name + ':' + $_.WS} 70

	# process names in colors based on working sets
	ps | Format-High Name 70 {@{f = if ($_.WS -gt 10mb) {'red'} else {'green'}}}

.Link
	https://github.com/nightroman/PowerShelf
#>

param
(
	[object]$Property,
	[int]$Width = $Host.UI.RawUI.WindowSize.Width - 1,
	[scriptblock]$Color,
	[object[]]$InputObject
)
try {
	if ($args) { throw "Unknown arguments: $args" }
	${private:-Property} = $Property
	${private:-Width} = $Width
	${private:-Color} = $Color
	${private:-InputObject} = $InputObject
	Remove-Variable Property, Width, Color, InputObject

	# process the input, color, get items as strings
	if ($null -eq ${-InputObject}) { ${-InputObject} = @($input) }
	try {
		$strings = if (${-Property} -is [string]) { ${-InputObject} | Select-Object -ExpandProperty ${-Property} }
		elseif (${-Property} -is [scriptblock]) { ${-InputObject} | ForEach-Object ${-Property} }
		else { ${-InputObject} }
	}
	catch { throw "Error on Property evaluation: $_" }
	try {
		$colors = @(if (${-Color}) { ${-InputObject} | ForEach-Object ${-Color} })
	}
	catch { throw "Error on Color evaluation: $_" }
	$strings = @(foreach($_ in $strings) { "$_" })

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
}
catch {
	Write-Error $_ -ErrorAction Stop
}
