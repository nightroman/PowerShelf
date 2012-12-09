
<#
.Synopsis
	Root test script.

.Description
	- Requires Invoke-Build.ps1 https://github.com/nightroman/Invoke-Build
	- To test all set location to this directory and invoke: Invoke-Build *
	- Tests may fail at not prepared machines or if PowerShell is not EN-US.
#>

task Add-Path { Invoke-Build * Add-Path.build.ps1 }
task Format-Chart { Invoke-Build * Format-Chart.build.ps1 }
task Format-High { Invoke-Build * Format-High.build.ps1 }
task Invoke-Environment { Invoke-Build * Invoke-Environment.build.ps1 }
task Submit-Gist { Invoke-Build * Submit-Gist.build.ps1 }
