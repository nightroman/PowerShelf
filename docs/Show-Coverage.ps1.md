# Show-Coverage.ps1

```
Converts to HTML and shows script coverage data.
Author: Roman Kuzmin
```

## Syntax

```
Show-Coverage.ps1 [-Data] Hashtable [[-Html] String] [[-Show] ScriptBlock]
```

## Description

```
This script converts script coverage data produced by Trace-Debugger.ps1 to
a HTML file and opens it by an associated application, normally the default
internet browser.

Coverage information is not always accurate because a tracing tool may not
step through all pieces of code and this script does not perform detailed
analysis of sources.
```

## Parameters

```
-Data <Hashtable>
    A hashtable with coverage data, e.g. produced by Trace-Debugger.ps1.
    
    Required?                    true
    Position?                    1
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```
-Html <String>
    Specifies the output HTML file.
    Default: $env:TEMP\Coverage.htm
    
    Required?                    false
    Position?                    2
    Default value                "$env:TEMP\Coverage.htm"
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```
-Show <ScriptBlock>
    Specifies the script block which opens the converted HTML file. The
    default script { Invoke-Item -LiteralPath $args[0] } opens it by the
    associated application, normally the default browser.
    
    Required?                    false
    Position?                    3
    Default value                {Invoke-Item -LiteralPath $args[0]}
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

## Inputs

```
None
```

## Outputs

```
None
```

## Examples

```
-------------------------- EXAMPLE 1 --------------------------
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

```
https://github.com/nightroman/PowerShelf
Trace-Debugger.ps1
```
