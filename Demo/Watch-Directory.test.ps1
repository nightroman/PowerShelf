
$env:BuildRoot = $BuildRoot

task BadPath {
	($r = try {<##> Watch-Directory.ps1 Missing} catch {$_})
	assert (($r | Out-String) -clike '*Missing directory:*<##>*FullyQualifiedErrorId : Missing directory: *\Missing,Watch-Directory.ps1*')
}

task BadInclude {
	($r = try {<##> Watch-Directory.ps1 . -Include *} catch {$_})
	assert (($r | Out-String) -clike '*Parameter Include:*<##>*FullyQualifiedErrorId : Parameter Include:*')
}

task BadExclude {
	($r = try {<##> Watch-Directory.ps1 . -Exclude *} catch {$_})
	assert (($r | Out-String) -clike '*Parameter Exclude:*<##>*FullyQualifiedErrorId : Parameter Exclude:*')
}

function Start-Test($Command) {
	Set-Variable -Scope 1 -Name ps -Value ([PowerShell]::Create().AddScript($Command))
	$null = $ps.BeginInvoke()
	Start-Sleep -Seconds 2
}

function Stop-Test {
	Start-Sleep -Seconds 3
	$ps.Stop()
}

task Deleted {
	Set-Content z.txt 42

	Start-Test {
		Watch-Directory.ps1 $env:BuildRoot -TestSeconds 1 -WaitSeconds 1 {
			param($changes)
			$changes | Export-Clixml $env:TEMP\z.clixml
		}
	}

	Remove-Item z.txt

	Stop-Test

	($r = Import-Clixml $env:TEMP\z.clixml)
	equals $r.Count 1
	$r = $r["$BuildRoot\z.txt"]
	equals $r 2

	Remove-Item $env:TEMP\z.clixml
}

task Changed {
	Start-Test {
		Watch-Directory.ps1 $env:BuildRoot -TestSeconds 1 -WaitSeconds 1 {
			param($changes)
			$changes | Export-Clixml $env:TEMP\z.clixml
		}
	}

	Set-Content z.txt 42

	Stop-Test

	($r = Import-Clixml $env:TEMP\z.clixml)
	equals $r.Count 1
	$r = $r["$BuildRoot\z.txt"]
	equals $r 4

	Remove-Item z.txt, $env:TEMP\z.clixml
}

task Renamed {
	Set-Content z.txt 42

	Start-Test {
		Watch-Directory.ps1 $env:BuildRoot -TestSeconds 1 -WaitSeconds 1 {
			param($changes)
			$changes | Export-Clixml $env:TEMP\z.clixml
		}
	}

	Rename-Item z.txt z.2.txt

	Stop-Test

	($r = Import-Clixml $env:TEMP\z.clixml)
	equals $r.Count 1
	$r = $r["$BuildRoot\z.2.txt"]
	equals $r 8

	Remove-Item z.2.txt, $env:TEMP\z.clixml
}

task Filters {
	Start-Test {
		Watch-Directory.ps1 $env:BuildRoot -Filter *.txt -Include \d -Exclude 2 -TestSeconds 1 -WaitSeconds 1 {
			param($changes)
			$changes | Export-Clixml $env:TEMP\z.clixml
		}
	}

	# Filter (-) Include (+) Exclude (+) = no
	Set-Content z.1.tmp 42

	# Filter (+) Include (-) Exclude (+) = no
	Set-Content z.txt 42

	# Filter (+) Include (+) Exclude (+) = yes
	Set-Content z.1.txt 42

	# Filter (+) Include (+) Exclude (-) = no
	Set-Content z.2.txt 42

	Stop-Test

	($r = Import-Clixml $env:TEMP\z.clixml)
	equals $r.Count 1
	$r = $r["$BuildRoot\z.1.txt"]
	equals $r 4

	Remove-Item z.1.tmp, z.txt, z.1.txt, z.2.txt, $env:TEMP\z.clixml
}
