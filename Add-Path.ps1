
<#
.Synopsis
	Adds a directory to an environment path variable.
	Author: Roman Kuzmin

.Description
	The script resolves the specified path, checks that the directory exists,
	and adds the path to an environment variable if it is not there yet. The
	changes are effective for the current process.

.Parameter Path
		Specifies the path to be added.
		Default is the current location.
.Parameter Name
		Specifies the environment variable to be updated.
		Default is 'PATH'.

.Inputs
	None
.Outputs
	None

.Example
	> Add-Path

	Adds the current location to the system path.

.Example
	> Add-Path TestModules PSModulePath

	Adds TestModules to the PowerShell module path.

.Link
	https://github.com/nightroman/PowerShelf
#>

param(
	[Parameter()]
	[string[]]$Path = '.',
	[string]$Name = 'PATH'
)

function Add-Path($Path) {
	# resolve and check
	$Path = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($Path)
	if (![System.IO.Directory]::Exists($Path)) { Write-Error "Missing directory '$Path'." -ErrorAction Stop }

	# already added?
	$var = [Environment]::GetEnvironmentVariable($Name)
	$trimmed = $Path.TrimEnd('\')
	foreach($dir in $var.Split(';')) {
		if ($dir.TrimEnd('\') -eq $trimmed) {
			return
		}
	}

	# add the path
	[Environment]::SetEnvironmentVariable($Name, $Path + ';' + $var)
}

try {
	foreach($Path in $Path) {
		Add-Path $Path
	}
}
catch {
	$PSCmdlet.ThrowTerminatingError($_)
}
