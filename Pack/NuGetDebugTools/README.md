
NuGetDebugTools - PowerShell Scripts
====================================

## Introduction

Simple and yet effective script debugging, tracing, coverage, and other tools.
They are designed for any PowerShell host and may be used in the NuGet console
for debugging and testing NuGet and Visual Studio specific scripts.

## The Package

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

## Installation

To install the tools for a Visual Studio solution, in the package manager
console invoke the usual command:

    Install-Package NuGetDebugTools

As a result, the package directory *tools* with scripts is added to the path
and the scripts can be invoked just by names.

Alternatively, the scripts can be placed anywhere in the path permanently in
order to make them available in package manager consoles for any solution,
without a solution, and for other PowerShell hosts, too.

## Quick Start

How to debug NuGet package scripts like *init.ps1*, *install.ps1*, and etc.?

Start Visual Studio. Open the NuGet console and invoke commands

    Add-Debugger.ps1
    Set-PSBreakpoint -Command init.ps1, install.ps1, uninstall.ps1

or set some more specific breakpoints, see `help Set-PSBreakpoint`.

Open a Visual Studio solution or invoke NuGet package commands for the already
opened. The debugger input dialog appears when the specified scripts are
invoked. Enter `?` in the debugger input box and see what you can do:

    s, StepInto  Step to the next statement into functions, scripts, etc.
    v, StepOver  Step to the next statement over functions, scripts, etc.
    o, StepOut   Step out of the current function, script, etc.
    c, Continue  Continue operation (also on Cancel or empty).
    q, Quit      Stop operation and exit the debugger.
    ?, h         Write this help message.
    k            Write call stack (Get-PSCallStack).
    K            Write detailed call stack using Format-List.

    <n>          Write debug location in context of <n> lines.
    +<n>         Set location context preference to <n> lines.
    k <s> <n>    Write source at stack <s> in context of <n> lines.

    w            Restart watching the debugger output file.
    r            Write last PowerShell commands invoked on debugging.
    <command>    Invoke any PowerShell <command> and write its output.

Type other debugger and PowerShell commands in order to step through the code,
view source code lines, or get variable values and watch the output in the
NuGet console window.

## The Project

The scripts come from [PowerShelf](https://github.com/nightroman/PowerShelf).
You may find there some related demo/test scripts and other PowerShell tools.
You are welcome to submit any issues or post questions there.
