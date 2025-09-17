# Set-ConsoleSize.ps1

```
Sets the current console size, interactively by default.
Author: Roman Kuzmin
```

## Syntax

```
Set-ConsoleSize.ps1 [[-Width] Object] [[-Height] Object]
```

## Description

```
The script allows resizing of the current console either interactively by
arrow keys (other keys stop resizing) or by specifying Width and/or Height.

The buffer width is always set equal to window width. The buffer height is
set equal to width if it was initially equal or not changed otherwise.
```

## Parameters

```
-Width <Object>
    New console width. Default is 0 (the current).
    
    Required?                    false
    Position?                    1
    Default value                0
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```
-Height <Object>
    New console height. Default is 0 (the current).
    
    Required?                    false
    Position?                    2
    Default value                0
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

## Inputs

```
None.
```

## Outputs

```
None.
```

## Examples

```
-------------------------- EXAMPLE 1 --------------------------
Set-ConsoleSize.ps1
Starts interactive resizing with arrow keys.
```

```
-------------------------- EXAMPLE 2 --------------------------
Set-ConsoleSize.ps1 80 25
Sets classic small console size.
```

```
-------------------------- EXAMPLE 3 --------------------------
Set-ConsoleSize.ps1 80
Sets only new width.
```

## Links

```
https://github.com/nightroman/PowerShelf
```
