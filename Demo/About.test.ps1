
<#
.Synopsis
	Common tests.

.Description
	Tests are invoked by Invoke-Build https://github.com/nightroman/Invoke-Build

	Invoke-Build **                     # all tests in this directory
	Invoke-Build * <file.test.ps1>      # all tests in a test file
	Invoke-Build <task> <file.test.ps1> # a test in a test file
#>

task HelpAndReadme -If ($PSVersionTable.PSVersion.Major -ge 3) {
	$README = Get-Content ..\README.md
	foreach($_ in Get-ChildItem .. -Filter *.ps1) {
		$_.FullName
		# help synopsis and the first link
		$r = Get-Help $_.FullName -Full
		assert (@($r.relatedLinks)[0].navigationLink.uri -eq 'https://github.com/nightroman/PowerShelf') "$_ : Expected help '.Link ../PowerShelf'."
		if ($r.Synopsis -notlike "*Author: Roman Kuzmin*") {
			# synopsis or meta must contain the author
			assert ((Get-Content $_.FullName) -cmatch '^\.AUTHOR Roman Kuzmin$') "$_ : Synopsis or meta must contain 'Author' info."
		}

		# README contains the file in the list
		assert (@($README -cmatch '^\* \*' + $_.Name + '\* - .+\.$').Count -eq 1) "$_ : README must contain the synopsis."
	}
}
