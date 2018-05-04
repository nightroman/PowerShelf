
# PowerShelf Release Notes

## v1.9.1

Add *Show-SolutionDgml.ps1*.

## v1.8.5

*Update-Gist.ps1* - use proper `SecurityProtocol`.

## v1.8.4

`Add-Path.ps1` accepts one or many paths.

## v1.8.3

Dispose watchers in `Watch-Directory.ps1`.

## v1.8.2

Remove zip after extraction in `Save-NuGetTool.ps1` (#7).

## v1.8.1

More effective `Invoke-PowerShell.ps1`.

## v1.8.0

New script `Invoke-PowerShell.ps1`.

## v1.7.0

`Sync-Directory.ps1`

- More effective comparison using Robocopy output.
- New parameter Arguments: Robocopy arguments.
- Do not warn about extra files in both.
- Show information about all files.
- Reworked logged info and colors.

## v1.6.2

Reworked `Watch-Directory.ps1` to avoid `Get-Event` issues (#4).

## v1.6.1

`Watch-Directory.ps1`: If the command is omitted then the script outputs change
info as text.

## v1.6.0

New `Watch-Directory.ps1` - File change watcher and handler.

## v1.5.1

Cmdlet binding in scripts.

## v1.5.0

New `Save-NuGetTool.ps1` - Downloads a NuGet package and extracts /tools.

Set package `developmentDependency` to true.

## v1.4.1

`Measure-Command2.ps1`

- Avoided `Out-Host` on `-Test`, data, if any, are returned before the duration.
- On failures a warning is shown. It tells to examine `$Error` for more details.

## v1.4.0

*Add-Debugger.ps1*. New switch `ReadHost` tells to use `Read-Host` for input
instead of the default GUI input box.

## v1.3.1

*Update-Gist.ps1*. Fixed JSON issues.

## v1.3.0

New script *Update-Gist.ps1*. It updates or creates a gist file. Unlike
*Submit-Gist.ps1* it does not require a git client, it uses the cmdlet
`Invoke-RestMethod` and GitHub API. Requires PowerShell 3.0+.

## v1.2.4

*Submit-Gist.ps1*: Added yet another form of expected gist URL.

## v1.2.3

*Invoke-Environment.ps1*: Fixed cases like one of the examples :)

*Add-Debugger.ps1*, *Trace-Debugger.ps1*: Adapted for PowerShell v4.0.

## v1.2.2

*Format-High.ps1*: When a window width is unknown use 80 as the default. As a
result, it works in PowerShell ISE, too. 80 is normally too small there but
data are shown, not an error. Then a proper width may be specified manually.

## v1.2.1

*Assert-SameFile.ps1*: PromptForChoice did not work in PS v2.0

## v1.2.0

*Assert-SameFile.ps1*

- Replaced `Read-Host` prompt with `PromptForChoice`.
- Added *Ignore* (default) in addition to *Update* and *Abort*.

## v1.1.2

Added *Sync-Directory.ps1*.

## v1.1.1

*Show-Coverage.ps1*: fixed links in HTML.

## v1.1.0

New script *Assert-SameFile.ps1* automates one typical test scenario, it
compares the sample and result files and performs copy and view operations.

## v1.0.0

NuGetDebugTools [v1.3.0](https://github.com/nightroman/PowerShelf/blob/master/Pack/NuGetDebugTools/Release-Notes.md#v130)
