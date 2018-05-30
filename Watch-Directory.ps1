
<#
.Synopsis
	File change watcher and handler.
	Author: Roman Kuzmin

.Description
	The script watches for changed, created, deleted, and renamed files in the
	given directories. On changes it invokes the specified command with change
	info. It is a dictionary where keys are changed file paths, values are last
	change types.

	If the command is omitted then the script outputs change info as text.

	The script works until it is forcedly stopped (Ctrl-C).

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
	$Command,
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

Add-Type @'
using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.IO;
using System.Text.RegularExpressions;

public class FileSystemWatcherHelper : IDisposable
{
	public string[] Path;
	public string Filter;
	public bool Recurse;

	public DateTime LastTime { get { return _lastTime; } }
	public bool HasChanges { get { return _changes.Count > 0; } }

	OrderedDictionary _changes = new OrderedDictionary();
	readonly List<FileSystemWatcher> _watchers = new List<FileSystemWatcher>();
	readonly object _lock = new object();
	DateTime _lastTime;
	Regex _include;
	Regex _exclude;

	public void Include(string pattern)
	{
		if (!string.IsNullOrEmpty(pattern))
			_include = new Regex(pattern, RegexOptions.IgnoreCase);
	}
	public void Exclude(string pattern)
	{
		if (!string.IsNullOrEmpty(pattern))
			_exclude = new Regex(pattern, RegexOptions.IgnoreCase);
	}
	public void Start()
	{
		foreach (string p in Path)
		{
			FileSystemWatcher watcher = new FileSystemWatcher(p);
			_watchers.Add(watcher);

			watcher.IncludeSubdirectories = Recurse;
			watcher.NotifyFilter = NotifyFilters.FileName | NotifyFilters.LastWrite;
			if (!string.IsNullOrEmpty(Filter))
				watcher.Filter = Filter;

			watcher.Created += OnChanged;
			watcher.Changed += OnChanged;
			watcher.Deleted += OnChanged;
			watcher.Renamed += OnChanged;
			watcher.EnableRaisingEvents = true;
		}
	}
	public object GetChanges()
	{
		lock (_lock)
		{
			object r = _changes;
			_changes = new OrderedDictionary();
			return r;
		}
	}
	public void Dispose()
	{
		foreach (FileSystemWatcher watcher in _watchers)
			watcher.Dispose();
		_watchers.Clear();
		_changes.Clear();
	}
	void OnChanged(object sender, FileSystemEventArgs e)
	{
		if (_include != null && !_include.IsMatch(e.Name))
			return;

		if (_exclude != null && _exclude.IsMatch(e.Name))
			return;

		lock (_lock)
		{
			_changes[e.FullPath] = e.ChangeType;
			_lastTime = DateTime.Now;
		}
	}
}
'@

$watcher = New-Object FileSystemWatcherHelper
$watcher.Path = $Path
$watcher.Filter = $Filter
$watcher.Recurse = $Recurse
try {$watcher.Include($Include)} catch {throw "Parameter Include: $_"}
try {$watcher.Exclude($Exclude)} catch {throw "Parameter Exclude: $_"}
try {
	$watcher.Start()
	for() {
		Start-Sleep -Seconds $TestSeconds

		if (!$watcher.HasChanges) {continue}
		if (([datetime]::Now - $watcher.LastTime).TotalSeconds -lt $WaitSeconds) {continue}

		$changes = $watcher.GetChanges()
		if ($Command) {
			try {
				& $Command $changes
			}
			catch {
				"$($_.ToString())`r`n$($_.InvocationInfo.PositionMessage)"
			}
		}
		else {
			foreach($kv in $changes.GetEnumerator()) {
				"$($kv.Value) $($kv.Key)"
			}
		}
	}
}
finally {
	$watcher.Dispose()
}
