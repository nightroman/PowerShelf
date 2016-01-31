
<#
.Synopsis
	File change watcher and handler.
	Author: Roman Kuzmin

.Description
	The tool watches for changed, created, deleted, and renamed files in the
	given directories. On changes it periodically invokes the specified command with
	a hastable, the last portion of change information.

	The hashtable keys are path of changed files, values are last change types.

.Parameter Path
		Specifies the watched directory paths.
.Parameter Command
		Specifies the command to process changes.
.Parameter Filter
		Simple and effective file system filter. Default *.*
.Parameter Pattern
		Inclusion regular expression pattern applied after Filter.
.Parameter Exclude
		Exclusion regular expression pattern applied after Filter.
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
	[array]$Path,
	[Parameter(Position=2)]
	$Command = {$args[0]},
	[string]$Filter,
	[string]$Pattern,
	[string]$Exclude,
	[switch]$Recurse,
	[int]$TestSeconds = 5,
	[int]$WaitSeconds = 5
)

trap {$PSCmdlet.ThrowTerminatingError($_)}
$Path = $Path |% { $PSCmdlet.GetUnresolvedProviderPathFromPSPath($_) }

$watchers = $Path |% {
	$watcher = [System.IO.FileSystemWatcher]$_
	$watcher.NotifyFilter = 'FileName,LastWrite'
	$watcher.IncludeSubdirectories = $Recurse
	if ($Filter) {
		$watcher.Filter = $Filter
	}
	$watcher
}

$events = @()
$SourceIdentifier = @()
$FileChanged, $FileCreated, $FileDeleted, $FileRenamed = $null
try {
	for ($i = 0; $i -lt $watchers.Count; $i++) {
		$WatcherEvents = "FileChanged_$i", "FileCreated_$i", "FileDeleted_$i", "FileRenamed_$i"
		$WatcherEvents |% {
			if (Get-EventSubscriber $_ -ErrorAction SilentlyContinue) {
				Unregister-Event $_
			}
		}

		$events += Register-ObjectEvent $watchers[$i] -EventName Changed -SourceIdentifier "FileChanged_$i"
		$events += Register-ObjectEvent $watchers[$i] -EventName Created -SourceIdentifier "FileCreated_$i"
		$events += Register-ObjectEvent $watchers[$i] -EventName Deleted -SourceIdentifier "FileDeleted_$i"
		$events += Register-ObjectEvent $watchers[$i] -EventName Renamed -SourceIdentifier "FileRenamed_$i"

		$SourceIdentifier += $WatcherEvents
	}

	$changes = @{}
	$lastTime = [datetime]::Now
	for() {
		Start-Sleep -Seconds $TestSeconds

		# events
		foreach($e in Get-Event) {
			if ($SourceIdentifier -notcontains $e.SourceIdentifier) {continue}

			$isMatch = $true
			if ($Pattern) {
				$isMatch = $isMatch -and ($e.SourceEventArgs.Name -match $Pattern)
			}
			if ($Exclude) {
				$isMatch = $isMatch -and ($e.SourceEventArgs.Name -notmatch $Exclude)
			}

			if ($isMatch) {
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
	$events |% {
		Unregister-Event -SourceIdentifier $_.Name -ErrorAction SilentlyContinue
	}
	$watchers |% { $_.Dispose() }
}
