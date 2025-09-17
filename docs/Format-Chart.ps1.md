# Format-Chart.ps1

```
Formats output as a table with the last chart column.
Author: Roman Kuzmin
```

## Syntax

```
Format-Chart.ps1 [-Property] String[] [[-Minimum] Object] [[-Maximum] Object] [[-Width] Int32] [[-BarChar] String] [[-SpaceChar] String] [[-InputObject] Object[]] [-Logarithmic]
```

## Description

```
The script is similar to Format-Table but it adds an extra column which
represents the last specified numeric property as the bar chart. Objects
with null chart data are excluded.
```

## Parameters

```
-Property <String[]>
    Property names. The last specifies a numeric property for the chart.
    
    Required?                    true
    Position?                    1
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```
-Minimum <Object>
    Minimum chart value. Default is the minimum property value.
    
    Required?                    false
    Position?                    2
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```
-Maximum <Object>
    Maximum chart value. Default is the maximum property value.
    
    Required?                    false
    Position?                    3
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```
-Width <Int32>
    Chart column width. Default is 1/2 of the screen buffer.
    
    Required?                    false
    Position?                    4
    Default value                ($Host.UI.RawUI.BufferSize.Width / 2)
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```
-BarChar <String>
    Character to fill chart bars. Default is [char]9632.
    
    Required?                    false
    Position?                    5
    Default value                ■
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```
-SpaceChar <String>
    Character to fill chart space. Default is space.
    
    Required?                    false
    Position?                    6
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```
-InputObject <Object[]>
    Input objects as an argument or piped.
    
    Required?                    false
    Position?                    7
    Accept pipeline input?       true (ByValue)
    Accept wildcard characters?  false
```

```
-Logarithmic [<SwitchParameter>]
    Tells to use the logarithmic scale.
    
    Required?                    false
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

## Inputs

```
Objects to be formatted.
```

## Outputs

```
Formatted data.
```

## Examples

```
-------------------------- EXAMPLE 1 --------------------------
Get-Process | Sort-Object WS | Format-Chart Name, WS
```

## Links

```
https://github.com/nightroman/PowerShelf
```
