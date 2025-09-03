
Set-StrictMode -Version 3
$Prefix = "http://127.0.0.1:9999"

Enter-Build {
	$pwsh = if ($PSEdition -eq 'Core') {'pwsh'} else {'powershell'}
	Start-Process $pwsh $PSScriptRoot/server.ps1 -WindowStyle Minimized
}

task add_text {
	$r = Invoke-RestMethod "$Prefix/add/text?A=13&B=27" -Method Post

	equals $r 40L
}

task add_json {
	$r = Invoke-RestMethod "$Prefix/add/json?A=13&B=27" -Method Post

	equals $r.Result 40L
	equals $r.Errors.Count 0
}

task show {
	$body = @{
		name = 'Joe'
		age = 27
	} | ConvertTo-Json

	$r = Invoke-RestMethod $Prefix/show?A=13 -Method Post -ContentType application/json -Body $body
	$r | ConvertTo-Json

	equals $r.Headers."Content-Type" "application/json"
	equals $r.Query.A '13'
	equals $r.Data.age 27L
}

task stop {
	$id = Invoke-RestMethod $Prefix
	Stop-Process -Id $id
}
