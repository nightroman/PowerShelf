
<#
.Synopsis
	Formats output as a table with the last chart column.
	Author: Roman Kuzmin

.Description
	The script is similar to Format-Table but it adds an extra column which
	represents the last specified numeric property as the bar chart. Objects
	with null chart data are excluded.

.Parameter Property
		Property names. The last specifies a numeric property for the chart.
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
		Input objects as an argument or piped.
.Parameter Logarithmic
		Tells to use the logarithmic scale.

.Inputs
	Objects to be formatted.
.Outputs
	Formatted data.

.Example
	Get-Process | Sort-Object WS | Format-Chart Name, WS

.Link
	https://github.com/nightroman/PowerShelf
#>

param(
	[Parameter(Mandatory=1)]
	[string[]]$Property,
	$Minimum,
	$Maximum,
	[int]$Width = ($Host.UI.RawUI.BufferSize.Width / 2),
	[string]$BarChar = [char]9632,
	[string]$SpaceChar = ' ',
	[Parameter(ValueFromPipeline=1)]
	[object[]]$InputObject,
	[switch]$Logarithmic
)

trap {$PSCmdlet.ThrowTerminatingError($_)}

if ($MyInvocation.ExpectingInput) {$InputObject = @($input)}
$name = $Property[-1]

# select properties + chart, skip nulls
$data = $InputObject | Select-Object ($Property + 'Chart') | .{process{if ($null -ne $_.$name) {$_}}}
if (!$data) {return}

# minimum, maximum, range
$mm = $data | Measure-Object $name -Minimum -Maximum
if ($mm.Minimum -isnot [double] -or $mm.Maximum -isnot [double]) {
	throw "Property '$name' should have numeric values."
}
if ($null -eq $Minimum) {
	$Minimum = $mm.Minimum
}
if ($null -eq $Maximum) {
	$Maximum = $mm.Maximum
}
$range = $Maximum - $Minimum
if ($range -lt 0) {
	throw "Invalid Minimum, Maximum: $Minimum, $Maximum."
}
if ($range -eq 0) {
	$range = 1
}

# set chart bars
foreach($_ in $data) {
	$factor = if ($Logarithmic) {
		[math]::Log(($_.$name - $Minimum + 1), ($range + 1))
	}
	else {
		($_.$name - $Minimum) / $range
	}

	if ($factor -lt 0) {
		$factor = 0
	}
	elseif ($factor -gt 1) {
		$factor = 1
	}

	$_.Chart = ($BarChar * ($Width * $factor)).PadRight($Width, $SpaceChar)
}

# format
Format-Table -AutoSize -InputObject $data
