
<#
.Synopsis
	Adds a directory to an environment path variable once.
	Author: Roman Kuzmin

.Description
	The script resolves the specified path, checks that the directory exists,
	and adds the path to an environment variable if it is not there yet. The
	changes are effective for the current process only.

.Parameter Path
		Path to add to an environment variable. Default is the current location.
.Parameter Name
		Environment variable to change. Default is 'PATH'.

.Inputs
	None. Use the parameters.
.Outputs
	None.

.Example
	>
	# Adds the current location to the system path
	Add-Path

	# Adds TestModules to the PowerShell modules
	Add-Path TestModules PSModulePath

.Link
	https://github.com/nightroman/PowerShelf
#>

param
(
	[Parameter()][string]$Path = '.',
	[string]$Name = 'PATH'
)

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
