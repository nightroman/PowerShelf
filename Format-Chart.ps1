
<#
.Synopsis
	Formats output as a table with the last chart column.
	Author: Roman Kuzmin

.Description
	The script works like Format-Table but it adds an extra chart column which
	represents the last specified property with bars of different widths. The
	last specified property should have numeric values.

.Parameter Property
		Properties where the last one is numeric for the chart.
.Parameter Minimum
		Minimum chart value. Default is the minimum property value.
.Parameter Maximum
		Maximum chart value. Default is the maximum property value.
.Parameter Width
		Chart column width. Default is 1/2 of the screen buffer.
.Parameter BarChar
		Character to fill chart bars. Default is [char]9632.
.Parameter SpaceChar
		Character to fill chart space. Default is space.
.Parameter InputObject
		Input objects. Default: the pipeline input.
.Parameter Logarithmic
		Tells to use the logarithmic scale.

.Inputs
	Objects to be formatted. Alternatively, use the parameter InputObject.
.Outputs
	Output of Format-Table.

.Example
	# Role of the parameter Minimum; compare two charts
	Get-Process | ?{$_.WS -gt 10Mb} | Format-Chart Name, WS
	Get-Process | ?{$_.WS -gt 10Mb} | Format-Chart Name, WS -Minimum 0

.Example
	# Custom bar character for shadow effects
	Get-Process | Format-Chart Name, WS -Bar ([char]9600) -Space ([char]9617)

.Link
	https://github.com/nightroman/PowerShelf
#>

param
(
	[object[]]$Property,
	$Minimum,
	$Maximum,
	[int]$Width = ($Host.UI.RawUI.BufferSize.Width / 2),
	[string]$BarChar = [char]9632,
	[string]$SpaceChar = ' ',
	[object[]]$InputObject,
	[switch]$Logarithmic
)
try {
	if ($args) { throw "Unknown arguments: $args" }
	if (!$Property) { throw "Missing parameter Property." }

	# select properties and add the chart
	$data = $(if ($InputObject) { $InputObject } else { @($Input) }) | Select-Object ($Property + 'Chart')
	if (!$data) {return}
	$name = $Property[-1]

	# get minimum and maximum and set range
	$mm = $data | Measure-Object $name -Minimum -Maximum
	if ($mm.Minimum -isnot [double] -or $mm.Maximum -isnot [double]) { throw "Property '$name' should have numeric values." }
	if ($null -eq $Minimum) { $Minimum = $mm.Minimum }
	if ($null -eq $Maximum) { $Maximum = $mm.Maximum }
	$range = $Maximum - $Minimum
	if ($range -lt 0) { throw "Invalid Minimum and Maximum: $Minimum, $Maximum." }
	if ($range -eq 0) { $range = 1 }

	# fill the chart column
	foreach($_ in $data) {
		if ($Logarithmic) {
			$factor = [math]::Log(($_.$name - $Minimum + 1), ($range + 1))
		}
		else {
			$factor = ($_.$name - $Minimum) / $range
		}
		if ($factor -lt 0) { $factor = 0 }
		elseif ($factor -gt 1) { $factor = 1 }
		$_.Chart = ($BarChar * ($Width * $factor)).PadRight($Width, $SpaceChar)
	}

	# format
	Format-Table -AutoSize -InputObject $data
}
catch {
	Write-Error $_ -ErrorAction Stop
}
