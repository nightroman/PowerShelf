
# PowerShelf Release Notes

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
