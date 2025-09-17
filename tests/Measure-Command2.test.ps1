
task error {
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

task withTest {
	($r = Measure-Command2.ps1 -Test {'result'})
	equals $r.Count 2
	equals $r[0] result
	assert ($r[1] -is [double])
}

task normal {
	($r = Measure-Command2.ps1 {'result'})
	assert ($r -is [double])
}

task twoCommands {
	($r1, $r2 = Measure-Command2.ps1 {'result1'}, {'result2'})
	assert ($r1 -is [double])
	assert ($r2 -is [double])
}

task twoCommandsWithTest {
	($r1, $r2, $r3, $r4 = Measure-Command2.ps1 -Test {'result1'}, {'result2'})
	equals $r1 result1
	assert ($r2 -is [double])
	equals $r3 result2
	assert ($r4 -is [double])
}
