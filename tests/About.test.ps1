<#
.Synopsis
	Common tests.
#>

task scripts {
	Set-Location ..
	foreach($_ in Get-ChildItem *-*.ps1) {
		$name = $_.FullName

		# has repo link
		$r = Get-Help $name -Full
		assert (@($r.relatedLinks)[0].navigationLink.uri -eq 'https://github.com/nightroman/PowerShelf') "$name : Expected '.Link https://github.com/nightroman/PowerShelf'."

		# has author info
		if ($r.Synopsis -cnotlike '*Author: Roman Kuzmin*') {
			assert ((Get-Content $name -Raw) -clike '*AUTHOR Roman Kuzmin*') "$name : Synopsis or meta must contain 'Author' info."
		}
	}
}
