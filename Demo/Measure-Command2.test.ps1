
task Error {
	($r = try {
		<#1#> Measure-Command2.ps1 {
			<#2#> throw 42
		}
	} catch {$_})

	equals $r.FullyQualifiedErrorId '42,Measure-Command2.ps1'
	assert ($r.InvocationInfo.PositionMessage -match '<#1#>')

	($r = $Error[0])
	equals $r.FullyQualifiedErrorId '42'
	assert ($r.InvocationInfo.PositionMessage -match '<#2#>')
}

task WithTest {
	($r = Measure-Command2.ps1 -Test {'result'})
	equals $r.Count 2
	equals $r[0] result
	assert ($r[1] -is [double])
}

task Normal {
	($r = Measure-Command2.ps1 {'result'})
	assert ($r -is [double])
}
