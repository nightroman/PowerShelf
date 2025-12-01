<#
.Synopsis
	Common tests.
#>

task scripts {
	Set-Location ..
	foreach($_ in Get-ChildItem *-*.ps1) {
		$name = $_.Name

		# has repo link
		$r = Get-Help $name -Full
		$url = @($r.relatedLinks)[0].navigationLink.uri
		assert -Message "$name : Unexpected .Link: $url" (
			$url -eq 'https://github.com/nightroman/PowerShelf' -or
			$url -eq "https://github.com/nightroman/PowerShelf/blob/main/docs/$name.md"
		)

		# has author info
		if ($r.Synopsis -cnotlike '*Author: Roman Kuzmin*') {
			assert ((Get-Content $name -Raw) -clike '*AUTHOR Roman Kuzmin*') "$name : Synopsis or meta must contain 'Author' info."
		}
	}
}
