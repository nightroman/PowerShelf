# PowerShelf Release Notes

## v1.13.9

`Add-Debugger.ps1` 2.2.0

- Support script modules properly.
- Invoke commands in the current scope.

## v1.13.8

`Add-Debugger.ps1` 2.1.0

- Open a new output console if the old is closed.
- Use PSReadLine for input when applicable.
- Use ANSI colors for source listing.

## v1.13.7

`Add-Debugger.ps1` 2.0.0

- use `Out-File` and support ANSI when PS 7.2+
- new parameter `Environment`, persist state
- use context with before/after line numbers
- replace `w` with `new` which removes output file

## v1.13.6

`Add-Debugger.ps1`

- use WinForms dialog as input box
- omit `w` in help when not available
- restore `$_` from parent scope if any
- `<empty>` repeats the last StepInto, StepOver

## v1.13.5

`Add-Debugger.ps1`

- recognise `$name = ...` and assign "expected" scope variable
- prettify

## v1.13.4

- `Add-Debugger.ps1`

    - Published at PSGallery.
    - New parameters `XPos`, `YPos`, for input box.
    - Use `pwsh` when the current process is `pwsh`.
    - New `d, Detach` commands for hosts with no debugger.

- `Test-Debugger.ps1`

    Slight change of default behaviour: set breakpoints and test them
    right away. Use -NoTest in order to set breakpoints without testing.

## v1.13.3

`Invoke-Ngen.ps1` - with `Recurse` assume `NoDependencies`.

## v1.13.2

`Assert-SameFile` - fix handling paths with spaces.

## v1.13.1

Redesign `Update-ReadmeIndex.ps1`.

## v1.13.0

New script `Update-ReadmeIndex.ps1`.

## v1.12.4

`Expand-Diff.ps1` - amend regex with tabs in path lines.

## v1.12.3

Amend `Invoke-PowerShell` for PS Core: if the current process is `pwsh` then
call its path else call `pwsh`. This works for custom `pwsh` and the dotnet
global tool, assuming the latter is in the path.

## v1.12.2

Amend `Invoke-PowerShell` for PS Core: if `pwsh` is available then call it else
try the current process. This works for `pwsh` installed as the dotnet tool.

## v1.12.1

Amend `Invoke-PowerShell` for PS v3-5 and possible not `ConsoleHost`.

## v1.12.0

- New script `Set-Env.ps1` and supportive `Set-Env.ArgumentCompleters.ps1`.
- `Submit-Gist.ps1` uses `https://gist.github.com/$GistId.git` for cloning.
- `Update-Gist.ps1` `-Credential` password is the GitHub OAUTH token.

## v1.11.4

Add `File` and `Argument` parameters to `Invoke-Environment`, #9

## v1.11.3

*Expand-Diff.ps1* - support reversed patches.

## v1.11.2

*Expand-Diff.ps1* - PowerShell v2 support, tests.

## v1.11.1

*Expand-Diff.ps1* - deal with encoded file names.

## v1.11.0

New script *Expand-Diff.ps1*.

## v1.10.0

New script *Invoke-Ngen.ps1*.

## v1.9.6

*Invoke-PowerShell.ps1* - refresh comments and slightly improve error handling.
Errors are possible on invoking with a script block argument due to the special
treatment by PowerShell.

## v1.9.5

*Show-SolutionDgml.ps1* - `Exclude` supports wildcards.

## v1.9.4

*Show-SolutionDgml.ps1*

- New parameter `Exclude`.
- On missing links write warnings, not errors.

## v1.9.3

- *Show-SolutionDgml.ps1* - add CSharp.Sdk type.
- *Watch-Directory.ps1* - use ordered dictionary for collected changes.

## v1.9.2

*Show-SolutionDgml.ps1* - add ServiceFabric type, amend tags.

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

NuGetDebugTools 1.3.0
