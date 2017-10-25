
<#
.Synopsis
	Format-Chart.ps1 tests.

.Notes
	# Custom bar character for shadow effects
	Get-Process | Format-Chart Name, WS -Bar ([char]9600) -Space ([char]9617)
#>

Set-StrictMode -Version Latest

task BadParameter {
	$ErrorActionPreference = 'Continue'
	($r = try {<##> Format-Chart.ps1 Name -Unknown foo} catch {$_})
	assert $r.InvocationInfo.PositionMessage.Contains('<##>')
	equals $r.FullyQualifiedErrorId 'NamedParameterNotFound,Format-Chart.ps1'
}

task NumericValues {
	$ErrorActionPreference = 'Continue'

	# in V3 null and strings make issues; V2 is less strict
	if ($PSVersionTable.PSVersion.Major -ge 3) {
		$NonNumeric = $(
			New-Object PSObject -Property @{Name='name1'; Data=3}
			New-Object PSObject -Property @{Name='name2'; Data='b'}
		)
	}
	else {
		$NonNumeric = $(
			New-Object PSObject -Property @{Name='name1'; Data='a'}
			New-Object PSObject -Property @{Name='name2'; Data='b'}
		)
	}

	($e = try {$NonNumeric | Format-Chart Name, Data} catch {$_ | Out-String})
	assert ($e -like "*\Format-Chart.ps1 : Property 'Data' should have numeric values.*\Format-Chart.test.ps1:*")
}

task InvalidMinimumMaximum {
	$ErrorActionPreference = 'Continue'
	($e = try {Get-Process -PID $PID | Format-Chart Name, WS -Minimum 1gb} catch {$_ | Out-String})
	assert ($e -like "*\Format-Chart.ps1 : Invalid Minimum, Maximum: *, *.*\Format-Chart.test.ps1:*")
}

task NoData {
	$io = @()
	$res = $io | Format-Chart Data
	equals $null $res
	$res = Format-Chart Data -InputObject $io
	equals $null $res

	$io = $null
	$res = $io | Format-Chart Data
	equals $null $res
	$res = Format-Chart Data -InputObject $io
	equals $null $res
}

function Trim
{
	$(foreach($_ in $Input) {if ($_ = $_.TrimEnd()) {$_}}) -join "`r`n"
}

$Input2 = $(
	New-Object PSObject -Property @{Name='name1'; Data=3}
	New-Object PSObject -Property @{Name='name2'; Data=9}
	New-Object PSObject -Property @{Name='name3'; Data=$null}
	New-Object PSObject -Property @{Name='name4'}
	$null
	1
)

task Input2Default {
	$res = $Input2 | Format-Chart Name, Data -Width 9 -BarChar * -SpaceChar . | Out-String -Stream | Trim
	$res
	assert ($res -eq @'
Name  Data Chart
----  ---- -----
name1    3 .........
name2    9 *********
'@)
}

task Param2Default {
	$res = Format-Chart Name, Data -Width 9 -BarChar * -SpaceChar . -InputObject $Input2 | Out-String -Stream | Trim
	$res
	assert ($res -eq @'
Name  Data Chart
----  ---- -----
name1    3 .........
name2    9 *********
'@)
}

task Input2Minimum {
	$res = $Input2 | Format-Chart Name, Data -Width 9 -BarChar * -SpaceChar . -Minimum 0 | Out-String -Stream | Trim
	$res
	assert ($res -eq @'
Name  Data Chart
----  ---- -----
name1    3 ***......
name2    9 *********
'@)
}

task Input2Logarithmic {
	$res = $Input2 | Format-Chart Name, Data -Width 9 -BarChar * -SpaceChar . -Minimum 0 -Logarithmic | Out-String -Stream | Trim
	$res
	assert ($res -eq @'
Name  Data Chart
----  ---- -----
name1    3 *****....
name2    9 *********
'@)
}
