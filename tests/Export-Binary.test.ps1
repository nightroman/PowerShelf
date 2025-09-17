
<#
.Synopsis
	Export-Binary.ps1 and Import-Binary.ps1 tests.
#>

$Version = $PSVersionTable.PSVersion.Major
Set-StrictMode -Version Latest

task Hashtable {
	$data = @{
		string = 'data1'
		int = 42
		double = 3.14
		date = [DateTime]::Now
		guid = [guid]::NewGuid()
	}

	Export-Binary.ps1 z.binary $data

	$r = Import-Binary.ps1 z.binary
	$r

	assert ($r -is [hashtable])
	equals $r.Count $data.Count
}

task Primitives {
	'data1', 42, 3.14, ([DateTime]::Now), ([guid]::NewGuid()) | Export-Binary.ps1 z.binary

	$r = Import-Binary.ps1 z.binary
	$r

	assert ($r -is [object[]])
	equals $r.Count 5
	equals $r[0] 'data1'
	equals $r[1] 42
	equals $r[2] 3.14
	assert ($r[3] -is [DateTime])
	assert ($r[4] -is [guid])
}

#! skip v6+, "System.IO.DirectoryInfo is not marked as serializable".
task FileSystemItems -If ($Version -le 5) {
	$items = Get-ChildItem
	$items | Export-Binary.ps1 z.binary

	($r = Import-Binary.ps1 z.binary)

	equals $r.Count $items.Count
	assert ($r[0] -is [System.IO.FileSystemInfo])
}

task CustomObjects -If ($PSVersionTable.PSVersion.Major -ge 3) {
	$d1 = New-Object PSObject -Property @{data='data1'}
	$d2 = New-Object PSObject -Property @{data='data2'}
	$d1, $d2 | Export-Binary.ps1 z.binary

	$r = Import-Binary.ps1 z.binary
	$r

	equals $r.Count 2
	equals $r[0].data 'data1'
	equals $r[1].data 'data2'
}

task Append {
	'data1' | Export-Binary.ps1 z.binary
	$r = Import-Binary.ps1 z.binary
	equals $r 'data1'

	'data2' | Export-Binary.ps1 z.binary -Append
	$r = Import-Binary.ps1 z.binary
	equals $r.Count 2
	equals $r[0] 'data1'
	equals $r[1] 'data2'
}

### Issues

# Get-Date in a hashtable is fine in V3
task Get-Date-V3 -If ($PSVersionTable.PSVersion.Major -ge 3) {
	@{ date = (Get-Date) } | Export-Binary.ps1 z.binary
	$r = Import-Binary.ps1 z.binary
	assert ($r.date -is [DateTime])
}

# Get-Date in a hashtable is troublesome in V2
task Get-Date-V2 -If ($PSVersionTable.PSVersion.Major -eq 2) {
	($e = try { @{ date = (Get-Date) } | Export-Binary.ps1 z.binary } catch {$_})
	assert ($e -like "*Type 'System.Management.Automation.PSObject' * is not marked as serializable.*")
}

task RecoverDataFromBrokenFile {
	# export is stopped in the middle
	($e = try { 1, 2, $host | Export-Binary.ps1 z.binary } catch {$_})
	assert ($e -like "*Type 'System.Management.Automation.Internal.Host.InternalHost' * is not marked as serializable.*")

	# recover some data from the broken file
	$r = Import-Binary.ps1 z.binary -ErrorAction 0 -ErrorVariable e
	assert ($e -like "*End of Stream encountered before parsing was completed.*")
	equals $r.Count 2
	equals $r[0] 1
	equals $r[1] 2
}

task Clean {
	Remove-Item z.binary
}
