# Format-High.ps1

```text
Formats output by columns with optional custom item colors.
Author: Roman Kuzmin
```

## Syntax

```text
Format-High.ps1 [[-Property] Object] [[-Width] Int32] [[-Color] ScriptBlock] [[-InputObject] Object[]]
```

## Description

```text
The script prints the property, expression, or input objects by columns and
determines a suitable column number automatically. As a result, it produces
quite compact output. Output width and custom item colors can be specified.

The script is named in contrast to Format-Wide which prints items by rows.
```

## Parameters

```text
-Property <Object>
    Specifies the property name or a script block operating on $_.
    If it is omitted then object string representations are shown.
    
    Required?                    false
    Position?                    1
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```text
-Width <Int32>
    The table widths. By default it is the window width minus 1.
    
    Required?                    false
    Position?                    2
    Default value                0
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```text
-Color <ScriptBlock>
    An optional scriptblock which for input objects $_ outputs hashtables
    @{ForegroundColor=...; BackgroundColor=...}. Keys can be shortened and
    omitted, e.g. this is valid: @{f='red'}.
    
    Required?                    false
    Position?                    3
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```text
-InputObject <Object[]>
    Input objects as an argument or piped.
    
    Required?                    false
    Position?                    4
    Accept pipeline input?       true (ByValue)
    Accept wildcard characters?  false
```

## Inputs

```text
Objects to be shown.
```

## Outputs

```text
None. Data are shown by Write-Host.
```

## Examples

```text
-------------------------- EXAMPLE 1 --------------------------
PS>
# file system items
Get-ChildItem $home | Format-High

# verb names, custom width
Get-Verb | Format-High Verb 80

# custom expression and width
Get-Process | Format-High {$_.Name + ':' + $_.WS} 80

# process names with colors based on working sets
Get-Process | Format-High Name 80 {@{f=if($_.WS -gt 10mb){'red'}else{'green'}}}
```

## Links

```text
https://github.com/nightroman/PowerShelf
```
