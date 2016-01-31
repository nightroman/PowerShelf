
<#
.Synopsis
	File change watcher and handler.
	Author: Roman Kuzmin

.Description
	The command watches for changed, created, deleted, and renamed files in the
	given directories. On changes it periodically invokes the specified command
	with a hastable, the last portion of change information.

	The hashtable keys are path of changed files, values are last change types.

.Parameter Path
		Specifies the watched directory paths.
.Parameter Command
		Specifies the command to process changes.
		It may be a script block or a command name.
.Parameter Filter
		Simple and effective file system filter. Default *.*
.Parameter Include
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
	[string[]]$Path,
	[Parameter(Position=2)]
	$Command = {$args[0]},
	[string]$Filter,
	[string]$Include,
	[string]$Exclude,
	[switch]$Recurse,
	[int]$TestSeconds = 5,
	[int]$WaitSeconds = 5
)

trap {$PSCmdlet.ThrowTerminatingError($_)}

$Path = foreach($_ in $Path) {
	$_ = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($_)
	if (!([System.IO.Directory]::Exists($_))) {
		throw "Missing directory: $_"
	}
	$_
}

$watchers = @()
$SourceIdentifier = @()
try {
	$i = 0
	foreach($_ in $Path) {
		$watcher = [System.IO.FileSystemWatcher]$_
		$watcher.NotifyFilter = 'FileName,LastWrite'
		$watcher.IncludeSubdirectories = $Recurse
		if ($Filter) {
			$watcher.Filter = $Filter
		}
		$watchers += $watcher

		++$i
		Register-ObjectEvent $watcher -EventName Changed -SourceIdentifier "FileChanged_$i"
		Register-ObjectEvent $watcher -EventName Created -SourceIdentifier "FileCreated_$i"
		Register-ObjectEvent $watcher -EventName Deleted -SourceIdentifier "FileDeleted_$i"
		Register-ObjectEvent $watcher -EventName Renamed -SourceIdentifier "FileRenamed_$i"
		$SourceIdentifier += "FileChanged_$i", "FileCreated_$i", "FileDeleted_$i", "FileRenamed_$i"
	}

	$changes = @{}
	$lastTime = [datetime]::Now
	for() {
		Start-Sleep -Seconds $TestSeconds

		# events
		foreach($e in Get-Event) {
			if ($SourceIdentifier -notcontains $e.SourceIdentifier) {continue}

			$isMatch = $true
			if ($Include) {
				$isMatch = $e.SourceEventArgs.Name -match $Include
			}
			if ($Exclude -and $isMatch) {
				$isMatch = $e.SourceEventArgs.Name -notmatch $Exclude
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

		# call
		try {
			& $Command $changes
		}
		catch {
			@"
$($_.ToString())
$($_.InvocationInfo.PositionMessage)
"@
		}

		# reset
		$changes = @{}
		$lastTime = [datetime]::Now
	}
}
finally {
	foreach($_ in $SourceIdentifier) {
		Unregister-Event -SourceIdentifier $_ -ErrorAction Continue
	}
	foreach($_ in $watchers) {
		$_.Dispose()
	}
}
