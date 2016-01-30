
<#
.Synopsis
	File change watcher and handler.
	Author: Roman Kuzmin

.Description
	The tool watches for changed, created, deleted, and renamed files in the
	directory. On changes it periodically invokes the specified command with
	a hastable, the last portion of change information.

	The hashtable keys are path of changed files, values are last change types.

.Parameter Path
		Specifies the watched directory path.
.Parameter Command
		Specifies the command to process changes.
.Parameter Filter
		Simple and effective file system filter. Default *.*
.Parameter Pattern
		Regular expression pattern applied in after Filter.
.Parameter Recurse
		Tells to watch files in subdirectories as well.
.Parameter TestSeconds
		Time to sleep between checks for change events.
.Parameter WaitSeconds
		Time to wait after the last change before processing.

.Link
	https://github.com/nightroman/PowerShelf
#>

param(
	[Parameter(Position=1, Mandatory=1)]
	[string]$Path,
	[Parameter(Position=2)]
	$Command = {$args[0]},
	[string]$Filter,
	[string]$Pattern,
	[switch]$Recurse,
	[int]$TestSeconds = 5,
	[int]$WaitSeconds = 5
)

trap {$PSCmdlet.ThrowTerminatingError($_)}
$Path = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($Path)

$watcher = [System.IO.FileSystemWatcher]$Path
$watcher.NotifyFilter = 'FileName,LastWrite'
$watcher.IncludeSubdirectories = $Recurse
if ($Filter) {
	$watcher.Filter = $Filter
}

$FileChanged, $FileCreated, $FileDeleted, $FileRenamed = $null
try {
	$FileChanged = Register-ObjectEvent $watcher -EventName Changed -SourceIdentifier FileChanged
	$FileCreated = Register-ObjectEvent $watcher -EventName Created -SourceIdentifier FileCreated
	$FileDeleted = Register-ObjectEvent $watcher -EventName Deleted -SourceIdentifier FileDeleted
	$FileRenamed = Register-ObjectEvent $watcher -EventName Renamed -SourceIdentifier FileRenamed
	$SourceIdentifier = 'FileChanged', 'FileCreated', 'FileDeleted', 'FileRenamed'

	$changes = @{}
	$lastTime = [datetime]::Now
	for() {
		Start-Sleep -Seconds $TestSeconds

		# events
		foreach($e in Get-Event) {
			if ($SourceIdentifier -notcontains $e.SourceIdentifier) {continue}
			if (!$Pattern -or $e.SourceEventArgs.Name -match $Pattern) {
				$changes[$e.SourceEventArgs.FullPath] = $e.SourceEventArgs.ChangeType
				$time = $e.TimeGenerated
				if ($lastTime -lt $time) {
					$lastTime = $time
				}
			}
			Remove-Event -EventIdentifier $e.EventIdentifier
		}

		# skip
		if (!$changes.Count) {continue}
		if (([datetime]::Now - $lastTime).TotalSeconds -lt $WaitSeconds) {continue}

		# process
		try {
			& $Command $changes
		}
		catch {
			Write-Error $_ -ErrorAction Continue
		}

		# reset
		$changes = @{}
		$lastTime = [datetime]::Now
	}
}
finally {
	if ($FileChanged) {Unregister-Event -SourceIdentifier FileChanged}
	if ($FileCreated) {Unregister-Event -SourceIdentifier FileCreated}
	if ($FileDeleted) {Unregister-Event -SourceIdentifier FileDeleted}
	if ($FileRenamed) {Unregister-Event -SourceIdentifier FileRenamed}
	$watcher.Dispose()
}
