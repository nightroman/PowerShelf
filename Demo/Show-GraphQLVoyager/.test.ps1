
task schema-1 {
	Show-GraphQLVoyager.ps1 schema-1.graphql -Output z.schema-1.html
	if ($PSEdition -eq 'Core') {
		$r = Get-FileHash z.schema-1.html
		equals $r.Hash 302CF806D49AE2420D3ED9B9B6BFFC57C742C9E06AC1545711ABFB7DDF59786A
	}
}

task netlify {
	Show-GraphQLVoyager.ps1 https://swapi-graphql.netlify.app/.netlify/functions/index -Output z.netlify.html
	if ($PSEdition -eq 'Core') {
		$r = Get-FileHash z.netlify.html
		equals $r.Hash 8C5CDBD4BECFDDFA5D388EAF8EE8D4C254FAE8BE08EBFB2F0AF26433F384C01C
	}
}

task missing_file {
	try {
		throw Show-GraphQLVoyager.ps1 c://missing.graphql
	}
	catch {
		"$_"
		assert ($_ -like "*Could not find file 'C:\missing.graphql'.*")
	}
}

task show -If $env:TestGraphQL {
	foreach($_ in Get-Item $env:TestGraphQL\*.graphql) {
		Show-GraphQLVoyager.ps1 $_
		Start-Sleep 1
	}
}

task clean {
	remove z.*
}
