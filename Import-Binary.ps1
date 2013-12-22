
<#
.Synopsis
	Imports objects using binary serialization.
	Author: Roman Kuzmin

.Description
	This command de-serializes objects from the specified binary file. Together
	with Export-Binary.ps1 it is used for data persistence between sessions.

.Parameter Path
		Specifies the path to the input file.

.Link
	https://github.com/nightroman/PowerShelf
.Link
	Export-Binary.ps1
#>

param
(
	[Parameter(Mandatory=1)]
	$Path
)

$Path = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($Path)
$formatter = New-Object System.Runtime.Serialization.Formatters.Binary.BinaryFormatter
$stream = New-Object System.IO.FileStream ($Path, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::Read)
try {
	$length = $stream.Length
	while($stream.Position -lt $length) {
		$formatter.Deserialize($stream)
	}
}
catch {
	Write-Error $_
}
finally {
	$stream.Close()
}
