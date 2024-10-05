
task schema-1 {
	Show-GraphQLVoyager.ps1 schema-1.graphql -Output z.schema-1.html
	if ($PSEdition -eq 'Core') {
		$r = Get-FileHash z.schema-1.html
		equals $r.Hash C39C2717680F64494F8AB135F7808161BFABD36351E32D9437232816C6EE9555
	}
}

task netlify {
	Show-GraphQLVoyager.ps1 https://swapi-graphql.netlify.app/.netlify/functions/index -Output z.netlify.html
	if ($PSEdition -eq 'Core') {
		$r = Get-FileHash z.netlify.html
		equals $r.Hash 9571A3A4A3DAF8410E8F14944910FABEE6AA2BC7F7D923F2EE6BD1EFF932BE9C
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

task clean {
	remove z.*
}
