# Test-Debugger.ps1

```text
Tests PowerShell debugging with breakpoints.
Author: Roman Kuzmin
```

## Syntax

```text
Test-Debugger.ps1 [-NoTest] [-RemoveBreakpoints]
```

## Description

```text
This scripts helps to get familiar with various breakpoints: command,
variable (reading, writing, reading and writing), and custom actions.
It is also useful for testing debuggers, e.g. Add-Debugger.ps1.

The script sets some breakpoints in itself and triggers them all during
execution. In order to set breakpoints without testing, use NoTest. In
order to remove breakpoints, use RemoveBreakpoints.

With built-in debuggers it is ready to use, e.g. with
- ConsoleHost
- VSCode PowerShell host
- Windows PowerShell ISE Host
- FarHost (in the main session)

Use it with a custom debugger, e.g. Add-Debugger.ps1, with
- Default Host (simple calls of PowerShell from .NET)
- Package Manager Host (Visual Studio NuGet console)
- FarHost
```

## Parameters

```text
-NoTest [<SwitchParameter>]
    Tells to set breakpoints and exit without testing.
    
    Required?                    false
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```text
-RemoveBreakpoints [<SwitchParameter>]
    Tells to remove breakpoints set for this script.
    
    Required?                    false
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

## Examples

```text
-------------------------- EXAMPLE 1 --------------------------
PS>
# add debugger (or use the built-in and skip this)
Add-Debugger.ps1

# set and test breakpoints
Test-Debugger.ps1
```

## Links

```text
https://github.com/nightroman/PowerShelf
```
