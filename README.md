
PowerShelf - PowerShell Scripts
===============================

## Introduction

PowerShell tools for various tasks implemented as scripts, mostly standalone.
They are designed for PowerShell v2.0 and v3.0.

## Script List

* *Add-Debugger.ps1* - Adds a script debugger to PowerShell.
* *Add-Path.ps1* - Adds a directory to an environment path variable.
* *Assert-SameFile.ps1* - Compares the sample and result files.
* *Debug-Error.ps1* - Enables debugging on terminating errors.
* *Export-Binary.ps1* - Exports objects using binary serialization.
* *Format-Chart.ps1* - Formats output as a table with the last chart column.
* *Format-High.ps1* - Formats output by columns with optional custom item colors.
* *Import-Binary.ps1* - Imports objects using binary serialization.
* *Invoke-Environment.ps1* - Invokes a command and imports its environment variables.
* *Measure-Command2.ps1* - Measure-Command with several iterations and progress.
* *Measure-Property.ps1* -  Counts properties grouped by names and types.
* *Set-ConsoleSize.ps1* - Sets the current console size, interactively by default.
* *Show-Color.ps1* - Shows all color combinations, color names and codes.
* *Show-Coverage.ps1* - Converts to HTML and shows script coverage data.
* *Submit-Gist.ps1* - Submits a file to its GitHub gist repository.
* *Test-Debugger.ps1* - Tests PowerShell debugging with breakpoints.
* *Trace-Debugger.ps1* - Provides script tracing and coverage data collection.
* *Watch-Command.ps1* - Invokes a command repeatedly and shows its one screen output.

## Get Scripts

The scripts are distributed as two NuGet packages:

- [PowerShelf](https://www.nuget.org/packages/PowerShelf/) (all scripts)
- [NuGetDebugTools](https://www.nuget.org/packages/NuGetDebugTools/) (debugging)

All scripts together with tests and other files can be downloaded to the
current directory as *PowerShelf.zip* by this PowerShell command:

    (New-Object Net.WebClient).DownloadFile("https://github.com/nightroman/PowerShelf/zipball/master", "PowerShelf.zip")
