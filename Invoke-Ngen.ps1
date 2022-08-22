<#PSScriptInfo
.VERSION 1.0.2
.AUTHOR Roman Kuzmin
.COPYRIGHT (c) Roman Kuzmin
.TAGS Performance Tool Ngen
.GUID dcdd1d48-3113-4b90-9842-d9eae293d897
.PROJECTURI https://github.com/nightroman/PowerShelf
.LICENSEURI http://www.apache.org/licenses/LICENSE-2.0
#>

<#
.Synopsis
	Invokes the Native Image Generator tool (ngen.exe).

.Description
	Use this tool to improve performance of managed applications. It creates
	native images and installs them into the native image cache. The runtime
	can use native images from the cache instead of using the just-in-time
	(JIT) compiler to compile original assemblies.

	The tool may print various errors "Failed to load dependency..." and etc.
	They are not necessarily problems, the tool still improves what it can.

.Parameter Alias
		Tells to set the alias `ngen` in the calling scope.
		Use the alias in order to call the tool directly.
		Example:
			ngen /?

.Parameter Update
		Tells to update native images that have become invalid. Without -Queue
		this operation may take several minutes. But you may see some improved
		performance immediately after that.

		If -Queue is specified, the updates are queued for the ngen service and
		the command finishes immediately. Updates run when the computer is idle.

.Parameter Queue
		Tells to queue updates for the ngen service. It is used with -Update.

.Parameter Directory
		Specifies the directory and tells to generate native images for its
		exe and dll files.

.Parameter Recurse
		With -Directory, tells to include child directories and sets
		-NoDependencies to true.

.Parameter Current
		Tells to generate native images for the currently loaded app assemblies.
		Of course, it is a PowerShell hosting app, either console or another host.

.Parameter NoDependencies
		With -Directory or -Current, tells to generate the minimum number of
		native images required. With -Recurse, tt is ignored and used as true.

.Example
	>

	# update native images in the local computer cache
	Invoke-Ngen -Update

	# generate images for exe and dll from a directory
	Invoke-Ngen -Directory . -Recurse

.Link
	https://docs.microsoft.com/en-us/dotnet/framework/tools/ngen-exe-native-image-generator

.Link
	https://github.com/nightroman/PowerShelf
#>

[CmdletBinding(DefaultParameterSetName='Usage')]
param(
	[Parameter(Mandatory=1, ParameterSetName = 'Alias')]
	[switch]$Alias
	,
	[Parameter(Mandatory=1, ParameterSetName = 'Update')]
	[switch]$Update
	,
	[Parameter(ParameterSetName = 'Update')]
	[switch]$Queue
	,
	[Parameter(Mandatory=1, ParameterSetName = 'Current')]
	[switch]$Current
	,
	[Parameter(Mandatory=1, ParameterSetName = 'Directory')]
	[string]$Directory
	,
	[Parameter(ParameterSetName = 'Directory')]
	[switch]$Recurse
	,
	[Parameter(ParameterSetName = 'Current')]
	[Parameter(ParameterSetName = 'Directory')]
	[switch]$NoDependencies
)

$ErrorActionPreference = 1
trap { Write-Error $_ }

if ($PSVersionTable.PSEdition -eq 'Core') {
	$ngen = powershell -NoProfile -Command 'Join-Path ([Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory()) ngen.exe'
}
else {
	$ngen = Join-Path ([Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory()) ngen.exe
}
if (!$ngen -or !(Test-Path -LiteralPath $ngen)) {
	throw "Cannot find ngen.exe"
}

if ($PSCmdlet.ParameterSetName -eq 'Alias') {
	Set-Alias ngen $ngen -Scope 1
	return
}

Set-Alias ngen $ngen

if ($PSCmdlet.ParameterSetName -eq 'Update') {
	if ($Queue) {
		ngen update /queue
	}
	else {
		ngen update
	}
	return
}

if ($PSCmdlet.ParameterSetName -eq 'Current') {
	foreach($_ in [AppDomain]::CurrentDomain.GetAssemblies()) {
		Write-Host $_.Location -ForegroundColor Cyan
		if ($NoDependencies) {
			ngen install $_.Location /NoDependencies /nologo
		}
		else {
			ngen install $_.Location /nologo
		}
	}
	return
}

if ($PSCmdlet.ParameterSetName -eq 'Directory') {
	$Directory = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($Directory)
	Get-ChildItem -LiteralPath $Directory -Recurse:$Recurse | .{process{
		if ($_.Extension -match '\.(exe|dll)$') {
			Write-Host $_.FullName -ForegroundColor Cyan
			if ($NoDependencies -or $Recurse) {
				ngen install $_.FullName /NoDependencies /nologo
			}
			else {
				ngen install $_.FullName /nologo
			}
		}
	}}
	return
}

Write-Host @'
Usage:
	Invoke-Ngen -Alias
	Invoke-Ngen -Update [-Queue]
	Invoke-Ngen -Current [-NoDependencies]
	Invoke-Ngen -Directory <path> [-Recurse] [-NoDependencies]
'@
