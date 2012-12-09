
<#
.Synopsis
	Shows all color combinations, color names and codes.
	Author: Roman Kuzmin

.Description
	The script shows all combinations of background and foreground colors as a
	table. The last columns are hexadecimal and decimal codes and color names.

.Inputs
	None.
.Outputs
	None.

.Link
	https://github.com/nightroman/PowerShelf
#>

foreach($back in 0..15) {
	foreach($fore in 0..15) {
		Write-Host -BackgroundColor $back -ForegroundColor $fore -NoNewline (" {0:X} " -f $fore)
	}
	Write-Host (' {0:X} {0:d2} {1}' -f $back, [ConsoleColor]$back)
}
