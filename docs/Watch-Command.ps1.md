# Watch-Command.ps1

```
Invokes a command repeatedly and shows its one screen output.
Author: Roman Kuzmin
```

## Syntax

```
Watch-Command.ps1 [[-Expression] ScriptBlock] [[-Seconds] Int32]
```

## Description

```
The script invokes a specified command repeatedly with specified pauses and
shows each time one screen of output. Long lines are truncated and lines
exceeding window height are discarded.

- The script is for the console PowerShell.exe
- Commands should not operate on console.
- * indicates truncated output lines.
- Tabs are replaced with spaces.
- Empty lines are removed.
- Use Ctrl-C to stop.
```

## Parameters

```
-Expression <ScriptBlock>
    Script block which output is being watched. Default is {Get-Process}.
    
    Required?                    false
    Position?                    1
    Default value                {Get-Process}
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```
-Seconds <Int32>
    Refresh rate in seconds. Default is 3.
    
    Required?                    false
    Position?                    2
    Default value                3
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

## Inputs

```
None. Use the parameters.
```

## Outputs

```
None.
```

## Links

```
https://github.com/nightroman/PowerShelf
```
