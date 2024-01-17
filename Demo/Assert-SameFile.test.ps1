<#
.Synopsis
	Tests Assert-SameFile.ps1.
#>

Set-StrictMode -Version 3

task SameFile {
	Assert-SameFile $BuildFile $BuildFile
}

task SameText {
	# empty text is fine
	Assert-SameFile -Text

	# text end is trimmed
	Assert-SameFile -Text 'A' "A  `r`r`n`n"

	# line ends are ignored
	Assert-SameFile -Text "A`rB`nC`r`nD" "A`nB`nC`nD`n"
	Assert-SameFile -Text "A`nB`nC`nD`n" "A`rB`nC`r`nD"
}

task MissingResult {
	try {
		throw Assert-SameFile $BuildFile missing
	}
	catch {
		assert ($_ -clike "*Missing result file 'missing'.")
	}
}

task DifferentFileFail {
	try {
		throw Assert-SameFile $BuildFile Add-Debugger.test.ps1
	}
	catch {
		assert ($_ -like "*Different sample '*\Assert-SameFile.test.ps1' and result 'Add-Debugger.test.ps1'.")
	}
}

task DifferentTextFail {
	try {
		throw Assert-SameFile a b -Text
	}
	catch {
		equals "$_" "Different sample and result text."
	}
}

task MissingSample {
	$data = @{}
	remove z

	# fake
	function Write-Warning {
		$data.Warning = $args[0]
	}

	Assert-SameFile z $BuildFile

	equals $data.Warning "Created missing sample file 'z'."
	assert (Test-Path z)
	Assert-SameFile z $BuildFile

	remove z
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
	remove z

	### Update

	1 > z
	$fake = @{}
	$fakeChoice = 1
	Assert-SameFile z $BuildFile { $fake.View = 1 }
	assert ($fake.Warning -clike "Different sample 'z' and result '$BuildFile'.")
	equals $fake.Caption 'Different result'
	equals $fake.View 1
	Assert-SameFile z $BuildFile
	remove z

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
	remove z
}

task DifferentTextView {
	$Warnings = ${*}.Warnings
	$n = $Warnings.Count

	$r = @{}
	Assert-SameFile a b -Text -View {
		$r.file1 = $args[0]
		$r.file2 = $args[1]
	}

	equals $r.Count 2
	equals $r.file1 (Join-Path $env:TEMP Sample.txt)
	equals $r.file2 (Join-Path $env:TEMP Result.txt)

	$text1 = [System.IO.File]::ReadAllText($r.file1)
	$text2 = [System.IO.File]::ReadAllText($r.file2)
	equals $text1 "a`n"
	equals $text2 "b`n"

	equals $Warnings.Count ($n + 1)
	equals $Warnings[-1].Message "Different sample and result text."
	$Warnings.RemoveAt($n)
}
