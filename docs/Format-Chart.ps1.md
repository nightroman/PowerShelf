# Format-Chart.ps1

```text
Formats output as a table with the last chart column.
Author: Roman Kuzmin
```

## Syntax

```text
Format-Chart.ps1 [-Property] String[] [[-Minimum] Object] [[-Maximum] Object] [[-Width] Int32] [[-BarChar] String] [[-SpaceChar] String] [[-InputObject] Object[]] [-Logarithmic]
```

## Description

```text
The script is similar to Format-Table but it adds an extra column which
represents the last specified numeric property as the bar chart. Objects
with null chart data are excluded.
```

## Parameters

```text
-Property <String[]>
    Property names. The last specifies a numeric property for the chart.
    
    Required?                    true
    Position?                    1
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```text
-Minimum <Object>
    Minimum chart value. Default is the minimum property value.
    
    Required?                    false
    Position?                    2
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```text
-Maximum <Object>
    Maximum chart value. Default is the maximum property value.
    
    Required?                    false
    Position?                    3
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```text
-Width <Int32>
    Chart column width. Default is 1/2 of the screen buffer.
    
    Required?                    false
    Position?                    4
    Default value                ($Host.UI.RawUI.BufferSize.Width / 2)
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```text
-BarChar <String>
    Character to fill chart bars. Default is [char]9632.
    
    Required?                    false
    Position?                    5
    Default value                ■
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```text
-SpaceChar <String>
    Character to fill chart space. Default is space.
    
    Required?                    false
    Position?                    6
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```text
-InputObject <Object[]>
    Input objects as an argument or piped.
    
    Required?                    false
    Position?                    7
    Accept pipeline input?       true (ByValue)
    Accept wildcard characters?  false
```

```text
-Logarithmic [<SwitchParameter>]
    Tells to use the logarithmic scale.
    
    Required?                    false
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

## Inputs

```text
Objects to be formatted.
```

## Outputs

```text
Formatted data.
```

## Examples

```text
-------------------------- EXAMPLE 1 --------------------------
Get-Process | Sort-Object WS | Format-Chart Name, WS
```

## Links

```text
https://github.com/nightroman/PowerShelf
```
