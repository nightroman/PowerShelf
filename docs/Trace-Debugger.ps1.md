# Trace-Debugger.ps1

```text
Provides script tracing and coverage data collection.
Author: Roman Kuzmin
```

## Syntax

```text
Trace-Debugger.ps1 [[-Command] String[]] [[-Filter] ScriptBlock]
```

```text
Trace-Debugger.ps1 [[-Command] String[]] [[-Filter] ScriptBlock] -Path String
```

```text
Trace-Debugger.ps1 [[-Command] String[]] [[-Filter] ScriptBlock] -Table String
```

## Description

```text
This script is designed as the alternative to "Set-PSDebug -Trace".
It avoids some known Set-PSDebug issues and provides extra features.

The script is useful for troubleshooting in the first place. Its second
goal is generating data on testing for further script coverage analysis.

The built-in PowerShell debugger is replaced by the debugger which performs
tracing. In order to restore the original debugger and stop tracing invoke
Restore-Debugger. This command also removes temporary breakpoints and
closes the output file if it is used.
```

## Parameters

```text
-Command <String[]>
    Specifies the commands which trigger tracing, often a script being
    traced. In fact, any breakpoint which is hit triggers tracing. The
    parameter just helps to set some breakpoints. Such breakpoints are
    removed automatically by Restore-Debugger.
    
    Required?                    false
    Position?                    1
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```text
-Filter <ScriptBlock>
    Specifies the filter scriptblock which tests the variable $ScriptName
    and returns $true in order to trace or $false in order to ignore.
    $ScriptName contains the full path of a script being invoked.
    
    The code must not change anything in the session, this may break normal
    program flow. For example, the operator -match must not be used because
    it changes the automatic variable $Matches and other code with $Matches
    may work incorrectly on tracing.
    
    Required?                    false
    Position?                    2
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```text
-Path <String>
    Specifies the file used instead of the default Write-Host output. The
    data are appended to this file. Thus, the same file may be used many
    times, e.g. on collecting code coverage data by several tests.
    
    The file remains opened until Restore-Debugger is called or PowerShell
    exits. Note that tracing may produce very large output. If this is a
    problem then try to use Filter to reduce output or Table to collect
    relatively compact coverage data.
    
    Required?                    true
    Position?                    named
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```text
-Table <String>
    Tells to collect script coverage data and specifies the variable name.
    The variable is a hashtable created in the global scope. The keys are
    script paths, values are hashtables where keys are line numbers and
    values are line pass counters.
    
    Coverage data can be shown as HTML by the script Show-Coverage.ps1.
    
    Required?                    true
    Position?                    named
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

## Inputs

```text
None
```

## Outputs

```text
None
```

## Examples

```text
-------------------------- EXAMPLE 1 --------------------------
PS>
How to trace Test-Debugger.ps1. Test-Debugger is invoked twice. The first
call simply sets breakpoints. The second call does actual work, not much.
Note that breakpoints are not triggered in a usual way on tracing because
the original debugger is replaced by the temporary tracing debugger. But
action script blocks specified for some breakpoints are still invoked.

# enable tracing with the trigger command
Trace-Debugger Test-Debugger

# invoke with tracing
Test-Debugger
Test-Debugger

# stop tracing
Restore-Debugger
```

```text
-------------------------- EXAMPLE 2 --------------------------
PS> How to collect and show script coverage data

# enable tracing with result data table
Trace-Debugger Test.ps1 -Table Coverage

# invoke with tracing
Test.ps1

# stop tracing
Restore-Debugger

# show coverage data
Show-Coverage $Coverage
```

## Links

```text
https://github.com/nightroman/PowerShelf
Show-Coverage.ps1
```
