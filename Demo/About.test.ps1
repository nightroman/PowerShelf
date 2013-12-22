
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
		# help synopsis and the first link
		$r = Get-Help $_.FullName -Full
		assert ($r.Synopsis -like "*.`nAuthor:*") $r.Synopsis
		assert (@($r.relatedLinks)[0].navigationLink.uri -eq 'https://github.com/nightroman/PowerShelf') $_

		# README contains the file in the list
		assert (@($README -cmatch '^\* \*' + $_.Name + '\* - .+\.$').Count -eq 1)
	}
}
