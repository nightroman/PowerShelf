# Debug-Error.ps1

```
Enables debugging on terminating errors.
```

## Syntax

```
Debug-Error.ps1 [[-Script] String[]] [[-Action] ScriptBlock] [-Off]
```

## Description

```
Enables breaking into the debugger on terminating errors automatically. The
script works in any host with a debugger, in the console it breaks into the
debugger, too. But troubleshooting is not that easy as in VS Code.

VS Code scenario. Let the PowerShell extension start and open its terminal.
For example, open a script. In the terminal invoke Debug-Error.ps1. Then
invoke a script. As a result, on errors VS Code breaks into the debugger
and opens the culprit script in the editor at the line with an error.

Without parameters this command enables debugging on failures globally.
Use the parameter Script in order to narrow the location of errors.
Use the switch Off in order to stop debugging on errors.

The command exploits updates of the variable StackTrace on terminating
errors. Setting this variable breakpoint enables debugging on failures.
```

## Parameters

```
-Script <String[]>
    Sets a breakpoint in each of the specified script files.
    See: Get-Help Set-PSBreakpoint -Parameter Script
    
    Required?                    false
    Position?                    1
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```
-Action <ScriptBlock>
    Specifies commands that run at each breakpoint.
    See: Get-Help Set-PSBreakpoint -Parameter Action
    
    Required?                    false
    Position?                    2
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```
-Off [<SwitchParameter>]
    Tells to stop debugging on errors.
    Other parameters are ignored.
    
    Required?                    false
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

## Links

```
https://github.com/nightroman/PowerShelf
```
