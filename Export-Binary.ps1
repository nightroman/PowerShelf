
<#
.Synopsis
	Exports objects using binary serialization.
	Author: Roman Kuzmin

.Description
	This command serializes objects to the specified binary file. Together with
	Import-Binary.ps1 it is used for data persistence between sessions.

	Objects should be serializable. The command stops on any serialization
	issues and in this case the output file is not complete, more likely.
	Nevertheless, objects written before an error can be recovered by
	Import-Binary.ps1 with ErrorAction set to Continue or Ignore.

	Note that in PowerShell V2 PSObject is not serializable.

.Inputs
	Objects to be serialized.

.Outputs
	None.

.Parameter Path
		Specifies the path to the output file.
.Parameter InputObject
		Specifies the objects to export. Use it either as the parameter for a
		single object or pipe several objects to the command.
.Parameter Append
		Tells to add the output to the end of the specified file.

.Link
	https://github.com/nightroman/PowerShelf
.Link
	Import-Binary.ps1
#>

param
(
	[Parameter(Mandatory=1)]
	[string]$Path,
	[Parameter(ValueFromPipeline=1)]
	$InputObject,
	[switch]$Append
)
begin {
	$ErrorActionPreference = 'Stop'
	$Path = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($Path)
	$formatter = New-Object System.Runtime.Serialization.Formatters.Binary.BinaryFormatter
	$mode = if ($Append) { [System.IO.FileMode]::Append } else { [System.IO.FileMode]::Create }
	$stream = New-Object System.IO.FileStream ($Path, $mode, [System.IO.FileAccess]::Write, [System.IO.FileShare]::None)
}
process {
	try {
		if ($null -ne $InputObject) {
			$formatter.Serialize($stream, $InputObject)
		}
	}
	catch {
		$stream.Close()
		Write-Error $_
	}
}
end {
	$stream.Close()
}
