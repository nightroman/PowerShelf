
<#
.Synopsis
	Sync-Directory.ps1 tests.
#>

Set-StrictMode -Version Latest

function New-Log {
	$script:log = @{
		Caption = ''
		Warning = @()
		WriteHost = @()
	}
}

# mock
function Write-Warning($_) {
	$log.Warning += $_
}

# mock
function Write-Host($Object, $ForegroundColor) {
	Microsoft.PowerShell.Utility\Write-Host @PSBoundParameters
	$log.WriteHost += $Object
}

# mock
Set-Alias Get-Choice Get-Choice2
function Get-Choice2 {
	$log.Caption = $args[0]
	$choice
}

task Missing {
	New-Log
	($e = try {Sync-Directory missing1 missing2} catch {$_})
	assert ($e -like "Directories '*\missing1' and '*\missing2' do not exist.*")
}

task MissingSource {
	remove z
	$null = mkdir z\target
	1 > z\target\new.txt

	New-Log
	$choice = 1
	Sync-Directory z\source z\target
	assert ($log.Caption -like "Mirror 2->1 '*\z\target' to '*\z\source'")
	assert ($log.Warning[0] -like "Directory1 '*\z\source' does not exist.")
	equals $log.Warning.Count 1
	assert (!(Test-Path z\source))

	New-Log
	$choice = 0
	Sync-Directory z\source z\target
	assert ($log.Caption -like "Mirror 2->1 '*\z\target' to '*\z\source'")
	assert ($log.Warning[0] -like "Directory1 '*\z\source' does not exist.")
	equals $log.Warning.Count 1
	assert (Test-Path z\source)

	New-Log
	Sync-Directory z\source z\target
	equals $log.Caption ''
	equals $log.Warning.Count 0

	remove z
}

task MissingTarget {
	remove z
	$null = mkdir z\source
	1 > z\source\new.txt

	New-Log
	$choice = 1
	Sync-Directory z\source z\target
	assert ($log.Caption -like "Mirror 1->2 '*\z\source' to '*\z\target'")
	assert ($log.Warning[0] -like "Directory2 '*\z\target' does not exist.")
	equals $log.Warning.Count 1
	assert (!(Test-Path z\target))

	New-Log
	$choice = 0
	Sync-Directory z\source z\target
	assert ($log.Caption -like "Mirror 1->2 '*\z\source' to '*\z\target'")
	assert ($log.Warning[0] -like "Directory2 '*\z\target' does not exist.")
	equals $log.Warning.Count 1
	assert (Test-Path z\target)

	New-Log
	Sync-Directory z\source z\target
	equals $log.Caption ''
	equals $log.Warning.Count 0

	remove z
}

task Cases {
	remove z
	$null = mkdir z\source\source-dir
	$null = mkdir z\target\target-dir
	$oldTime = [datetime]'2000-01-01'

	# new, extra
	1 > z\source\new.txt
	1 > z\target\extra.txt

	# mismatch
	1 > z\source\target-dir
	1 > z\target\source-dir

	# newer
	1 > z\source\newer.txt
	1 > z\target\newer.txt
	(Get-Item z\target\newer.txt).LastWriteTime = $oldTime

	# older
	1 > z\source\older.txt
	1 > z\target\older.txt
	(Get-Item z\source\older.txt).LastWriteTime = $oldTime

	New-Log
	$choice = 0
	Sync-Directory z\source z\target

	equals $log.Caption Choose

	equals $log.Warning.Count 2
	equals $log.Warning[0] '2 mismatched'
	equals $log.Warning[1] 'Both directories have newer files.'

	# head
	$r = $log.WriteHost
	assert ($r[0] -like 'Directory1: *\z\source')
	assert ($r[1] -like 'Directory2: *\z\target')

	# tail
	$n = 8
	equals $r[2 + $n] ''
	assert ($r[3 + $n] -like "1 newer in '*\z\source'")
	assert ($r[4 + $n] -like "1 newer in '*\z\target'")
	assert ($r[5 + $n] -like "2 extra in '*\z\source'")
	assert ($r[6 + $n] -like "2 extra in '*\z\target'")

	# body
	($info = $r[2 .. (1 + $n)] | .{process{
		$_ = $_ -replace ' ', '~' -replace '\t', '|'
		$_.Replace($BuildRoot, '...')
	}} | Out-String)
	equals $info @'
|~~*EXTRA~File~|||...\z\target\extra.txt
|~~*MISMATCH~~~|||...\z\source\target-dir
|~~~~New~File~~|||...\z\source\target-dir
|~~~~New~File~~|||...\z\source\new.txt
|~~~~Newer~~~~~|||...\z\source\newer.txt
|~~~~Older~~~~~|||...\z\source\older.txt
|*MISMATCH~~~|...\z\source\source-dir\
|~~*EXTRA~File~|||...\z\target\source-dir

'@
	remove z
}
