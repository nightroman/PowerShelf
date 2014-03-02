
<#
.Synopsis
	Tests Assert-SameFile.ps1.
#>

Set-StrictMode -Version Latest

task SameFile {
	Assert-SameFile $BuildFile $BuildFile
}

task MissingResult {
	$$ = try { Assert-SameFile $BuildFile missing } catch {$_}
	$$
	assert ($$ -clike "*Missing result file 'missing'.")
}

task DifferentFileFail {
	$$ = try { Assert-SameFile $BuildFile Add-Debugger.test.ps1 } catch {$_}
	$$
	assert ($$ -like "*Different sample '*\Assert-SameFile.test.ps1' and result 'Add-Debugger.test.ps1'.")
}

task MissingSample {
	$data = @{}
	Remove-Item [z]

	# fake
	function Write-Warning {
		$data.Warning = $args[0]
	}

	Assert-SameFile z $BuildFile

	assert ($data.Warning -ceq "Created missing sample file 'z'.")
	assert (Test-Path z)
	Assert-SameFile z $BuildFile

	Remove-Item z
}

task DifferentFileUpdate {
	$data = @{}
	42 > z

	# fake
	function Write-Warning {
		$data.Warning = $args[0]
	}
	function Read-Host {
		$data.Read = $args[0]
		'1'
	}

	Assert-SameFile z $BuildFile { $data.View = 1 }

	assert ($data.Warning -clike "Different sample 'z' and result '$BuildFile'.")
	assert ($data.Read -ceq '[1] Update sample [0] Abort')
	assert ($data.View -eq 1)

	Assert-SameFile z $BuildFile

	Remove-Item z
}

task DifferentFileAbort {
	$data = @{}
	42 > z

	# fake
	function Write-Warning {
		$data.Warning = $args[0]
	}
	function Read-Host {
		$data.Read = $args[0]
		'0'
	}

	$$ = try { Assert-SameFile z $BuildFile { $data.View = 1 } } catch {$_}
	$$
	assert ($$ -clike "*Different sample 'z' and result '$BuildFile'.")
	assert ((Get-Content z) -eq 42)

	assert ($data.Warning -clike "Different sample 'z' and result '$BuildFile'.")
	assert ($data.Read -ceq '[1] Update sample [0] Abort')
	assert ($data.View -eq 1)

	Remove-Item z
}
