
PowerShelf - PowerShell Scripts
===============================

This is a set of PowerShell scripts for various tasks.
They are designed and tested for PowerShell v2 and v3.

## Script List

* *Add-Path.ps1* - Adds a directory to an environment path variable once.
* *Format-Chart.ps1* - Formats output as a table with the last chart column.
* *Format-High.ps1* - Formats output by columns with optional custom item colors.
* *Measure-Command2.ps1* - Measure-Command with several iterations and progress.
* *Set-ConsoleSize.ps1* - Sets the current console size, interactively by default.
* *Submit-Gist.ps1* - Submits a file to its GitHub gist repository.
* *Watch-Command.ps1* - Invokes a command repeatedly and shows its one screen output.

The directory *Demo* contains demo scripts and tests invoked by [*Invoke-Build.ps1*](https://github.com/nightroman/Invoke-Build).

## Get Scripts

The scripts can be downloaded as the archive *PowerShelf.zip* to the current
process directory by this PowerShell command:

    (New-Object Net.WebClient).DownloadFile("https://github.com/nightroman/PowerShelf/zipball/master", "PowerShelf.zip")
