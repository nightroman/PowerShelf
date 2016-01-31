
$env:BuildRoot = $BuildRoot

task Deleted {
	Set-Content z.txt 42
	$ps = [PowerShell]::Create().AddScript({
		Watch-Directory.ps1 $env:BuildRoot -TestSeconds 1 -WaitSeconds 1 {
			param($changes)
			$changes | Export-Clixml $env:TEMP\z.clixml
		}
	})
	$null = $ps.BeginInvoke()
	Start-Sleep -Seconds 2
	Remove-Item z.txt
	Start-Sleep -Seconds 3
	$ps.Stop()
	($r = Import-Clixml $env:TEMP\z.clixml)
	equals $r.Count 1
	$r = $r["$BuildRoot\z.txt"]
	equals $r 2
	Remove-Item $env:TEMP\z.clixml
}

task Changed {
	$ps = [PowerShell]::Create().AddScript({
		Watch-Directory.ps1 $env:BuildRoot -TestSeconds 1 -WaitSeconds 1 {
			param($changes)
			$changes | Export-Clixml $env:TEMP\z.clixml
		}
	})
	$null = $ps.BeginInvoke()
	Start-Sleep -Seconds 2
	Set-Content z.txt 42
	Start-Sleep -Seconds 3
	$ps.Stop()
	($r = Import-Clixml $env:TEMP\z.clixml)
	equals $r.Count 1
	$r = $r["$BuildRoot\z.txt"]
	equals $r 4
	Remove-Item z.txt, $env:TEMP\z.clixml
}

task Renamed {
	Set-Content z.txt 42
	$ps = [PowerShell]::Create().AddScript({
		Watch-Directory.ps1 $env:BuildRoot -TestSeconds 1 -WaitSeconds 1 {
			param($changes)
			$changes | Export-Clixml $env:TEMP\z.clixml
		}
	})
	$null = $ps.BeginInvoke()
	Start-Sleep -Seconds 2
	Rename-Item z.txt z.2.txt
	Start-Sleep -Seconds 3
	$ps.Stop()
	($r = Import-Clixml $env:TEMP\z.clixml)
	equals $r.Count 1
	$r = $r["$BuildRoot\z.2.txt"]
	equals $r 8
	Remove-Item z.2.txt, $env:TEMP\z.clixml
}
