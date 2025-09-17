
task Help0 {
	Convert-HelpToDocs.ps1 ./Test-Help0.ps1 z.txt
}

task Test-1 {
	. ./Test-Help1.ps1
	Convert-HelpToDocs.ps1 Test-1 z.txt
}
