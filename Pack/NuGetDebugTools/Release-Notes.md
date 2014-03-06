
NuGetDebugTools Release Notes
=============================

## v1.3.1

Show-Coverage.ps1: fixed links in HTML.

## v1.3.0

*Show-Coverage.ps1* - This new tool is used together with *Trace-Debugger.ps1*
in order to convert coverage data to HTML and visualize script coverage
information.

## v1.2.0

*Trace-Debugger.ps1*

This script is the new tool, the alternative to `Set-PSDebug -Trace`. It avoids
known `Set-PSDebug` V3 issues and provides some extra features. It is useful
for troubleshooting and collecting data for script coverage analysis.

Consider it as yet experimental, its features may change.

*Add-Debugger.ps1*

Removes another debugger by `Restore-Debugger`. Thus, *Add-Debugger.ps1* and
*Trace-Debugger.ps1* may be used together in the same session. But just one
debugger may be currently in use.

## v1.1.0

It is possible to use the debugger instead of the built-in (tested for console
host, ISE, FarHost). The new function `Restore-Debugger` restores the original
debugger.

## v1.0.0

Debugger output file path may contain special symbols like ``` `'[] ```.

Failed PowerShell commands are also added to the history.

Minor tweaks in code, documentation, and tests.

## v0.3.0

The features look stabilized, it's v1 candidate.

*Add-Debugger.ps1*

- Removed parameter `Watch`. The function `Watch-Debugger` is used instead.
- Renamed parameter `FilePath` to `Path`.

## v0.2.1

Command `k <s> <n>` writes the script path as well.

## v0.2.0

*Add-Debugger.ps1* - new parameters `FilePath` and `Watch` provide the debug
mode without `Write-Host` which is not always available or suitable. Renamed
used functions using the common prefix *Debugger*.

*Debug-Error.ps1* - new parameter `Script` allows setting terminating error
breakpoints for specified scripts ignoring other errors (e.g. caught and
processed in other scripts, happened in the command line, etc.).

*Test-Debugger.ps1* - avoided `Write-Host`, so that it is easier to use in
hosts without this cmdlet supported.

## v0.1.1

Amended processing of the debugger command Quit.

When the special variable breakpoint on `StackTrace` is hit the message
TERMINATING ERROR BREAKPOINT is written instead of the standard (see
*Debug-Error.ps1* about this breakpoint).

Added *Test-Debugger.ps1* to the package.

## v0.1.0

Debugging of script modules is supported as well.

## v0.0.3

New command `k <s> <n>` writes source at stack `<s>` (0 is the current, 1 is
the parent, etc.) in context of `<n>` lines.

## v0.0.2

New command `K` displays the detailed call stack using `Format-List`.

The debugger input box shows the last command as the default.

Added *Quick Start* section to *README*.

## v0.0.1

The first public version.
