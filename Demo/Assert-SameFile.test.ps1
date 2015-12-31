
<#
.Synopsis
	Tests Assert-SameFile.ps1.
#>

Set-StrictMode -Version Latest

task SameFile {
	Assert-SameFile $BuildFile $BuildFile
}

task MissingResult {
	($e = try {Assert-SameFile $BuildFile missing} catch {$_})
	assert ($e -clike "*Missing result file 'missing'.")
}

task DifferentFileFail {
	($e = try {Assert-SameFile $BuildFile Add-Debugger.test.ps1} catch {$_})
	assert ($e -like "*Different sample '*\Assert-SameFile.test.ps1' and result 'Add-Debugger.test.ps1'.")
}

task MissingSample {
	$data = @{}
	Remove-Item [z]

	# fake
	function Write-Warning {
		$data.Warning = $args[0]
	}

	Assert-SameFile z $BuildFile

	equals $data.Warning "Created missing sample file 'z'."
	assert (Test-Path z)
	Assert-SameFile z $BuildFile

	Remove-Item z
}

task DifferentFile {
	# fake
	function Write-Warning {
		$fake.Warning = $args[0]
	}
	function Get-Choice2 {
		$fake.Caption = $args[0]
		$fakeChoice
	}
	Set-Alias Get-Choice Get-Choice2

	### Ignore

	0 > z
	$fake = @{}
	$fakeChoice = 0
	Assert-SameFile z $BuildFile { $fake.View = 0 }
	assert ($fake.Warning -clike "Different sample 'z' and result '$BuildFile'.")
	equals $fake.Caption 'Different result'
	equals $fake.View 0
	equals (Get-Content z) '0'
	Remove-Item z

	### Update

	1 > z
	$fake = @{}
	$fakeChoice = 1
	Assert-SameFile z $BuildFile { $fake.View = 1 }
	assert ($fake.Warning -clike "Different sample 'z' and result '$BuildFile'.")
	equals $fake.Caption 'Different result'
	equals $fake.View 1
	Assert-SameFile z $BuildFile
	Remove-Item z

	### Abort

	2 > z
	$fake = @{}
	$fakeChoice = 2
	($e = try {Assert-SameFile z $BuildFile { $fake.View = 2 }} catch {$_})
	assert ($fake.Warning -clike "Different sample 'z' and result '$BuildFile'.")
	equals $fake.Caption 'Different result'
	equals $fake.View 2
	assert ($e -like "*Different sample 'z' and result '$BuildFile'.")
	equals (Get-Content z) '2'
	Remove-Item z
}
