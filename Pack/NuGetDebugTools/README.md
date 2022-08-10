# NuGetDebugTools - PowerShell Scripts

> NuGetDebugTools is no longer published as the separate NuGet package.
> Use PowerShelf instead, with all NuGetDebugTools scripts included.

*Add-Debugger.ps1* - Adds a simple debugger to PowerShell. As far as the NuGet
console does not provide its own debugger, this script comes to rescue. It can
be also used for debugging with custom or default hosts, e.g. on invoking
PowerShell code from .NET code.

*Trace-Debugger.ps1* - This script is the alternative to `Set-PSDebug -Trace`.
It avoids some known `Set-PSDebug` V3 issues and provides extra features. It is
useful in any host for troubleshooting and collecting data for script coverage
analysis.

*Show-Coverage.ps1* - It is used together with *Trace-Debugger.ps1* in order to
convert coverage data to HTML and visualize script coverage information.

*Debug-Error.ps1* - Enables debugging on terminating errors. PowerShell does
not provide a way to break into debugger on errors. This script enables this
feature by exploiting a known fact about the automatic variable `StackTrace`.
Designed for any host with a debugger.

*Test-Debugger.ps1* - Tests PowerShell debugging with breakpoints. It is
suitable for playing with any debugger though it is designed for custom
debuggers like *Add-Debugger.ps1*.
