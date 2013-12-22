
<#
.Synopsis
	Export-Binary.ps1 and Import-Binary.ps1 tests.
#>

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
	assert ($r.Count -eq $data.Count)
}

task Primitives {
	'data1', 42, 3.14, ([DateTime]::Now), ([guid]::NewGuid()) | Export-Binary.ps1 z.binary

	$r = Import-Binary.ps1 z.binary
	$r

	assert ($r -is [object[]])
	assert ($r.Count -eq 5)
	assert ($r[0] -ceq 'data1')
	assert ($r[1] -eq 42)
	assert ($r[2] -eq 3.14)
	assert ($r[3] -is [DateTime])
	assert ($r[4] -is [guid])
}

task FileSystemItems {
	$items = Get-ChildItem
	$items | Export-Binary.ps1 z.binary

	$r = Import-Binary.ps1 z.binary
	$r

	assert ($r.Count -eq $items.Count)
	assert ($r[0] -is [System.IO.FileInfo])
}

task CustomObjects -If ($PSVersionTable.PSVersion.Major -ge 3) {
	$d1 = New-Object PSObject -Property @{data='data1'}
	$d2 = New-Object PSObject -Property @{data='data2'}
	$d1, $d2 | Export-Binary.ps1 z.binary

	$r = Import-Binary.ps1 z.binary
	$r

	assert ($r.Count -eq 2)
	assert ($r[0].data -eq 'data1')
	assert ($r[1].data -eq 'data2')
}

task Append {
	'data1' | Export-Binary.ps1 z.binary
	$r = Import-Binary.ps1 z.binary
	assert ($r -eq 'data1')

	'data2' | Export-Binary.ps1 z.binary -Append
	$r = Import-Binary.ps1 z.binary
	assert ($r.Count -eq 2)
	assert ($r[0] -eq 'data1')
	assert ($r[1] -eq 'data2')
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
	$e = try { @{ date = (Get-Date) } | Export-Binary.ps1 z.binary } catch {$_}
	assert ($e -like "*Type 'System.Management.Automation.PSObject' * is not marked as serializable.*")
}

task RecoverDataFromBrokenFile {
	# export is stopped in the middle
	$e = try { 1, 2, $host | Export-Binary.ps1 z.binary } catch {$_}
	assert ($e -like "*Type 'System.Management.Automation.Internal.Host.InternalHost' * is not marked as serializable.*")

	# recover some data from the broken file
	$r = Import-Binary.ps1 z.binary -ErrorAction 0 -ErrorVariable e
	assert ($e -like "*End of Stream encountered before parsing was completed.*")
	assert ($r.Count -eq 2)
	assert ($r[0] -eq 1)
	assert ($r[1] -eq 2)
}

task Clean {
	Remove-Item z.binary
}
