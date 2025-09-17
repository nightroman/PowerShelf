# Add-Debugger.ps1

```text
Debugger for PowerShell hosts with no own debuggers.
```

## Syntax

```text
Add-Debugger.ps1 [[-Path] String] [-Context Int32[]] [-Environment String] [-WriteHost]
```

```text
Add-Debugger.ps1 [[-Path] String] [-Context Int32[]] [-Environment String] [-WriteHost] -ReadGui
```

```text
Add-Debugger.ps1 [[-Path] String] [-Context Int32[]] [-Environment String] [-WriteHost] -ReadHost
```

## Description

```text
The script adds or replaces existing debugger in any runspace. It is
useful for hosts with no own debuggers, e.g. 'Default Host', 'Package
Manager Host', 'FarHost'. Or it may replace existing debuggers, e.g.
in "ConsoleHost".

The script is called at any moment when debugging is needed. To restore
the original debuggers, invoke Restore-Debugger defined by Add-Debugger.

Console like hosts include 'ConsoleHost', 'Visual Studio Code Host',
'Package Manager Host'. They imply using Read-Host and Write-Host by
default. Other hosts use GUI input box and output file watching.
```

## Parameters

```text
-Path <String>
    Specifies the file used for debugger output. A separate console is
    used for watching its tail. Do not let the file to grow too large.
    Invoke `new` when watching gets slower.
    
    "$env:TEMP\$Environment.log" is used by default.
    The default file is deleted before debugging.
    
    Required?                    false
    Position?                    1
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```text
-Context <Int32[]>
    One or two integers, shown line counts before and after the current.
    
    @(4, 4) is used by default.
    
    Required?                    false
    Position?                    named
    Default value                @(4, 4)
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```text
-Environment <String>
    Specifies the environment name for saving the state. It is also used as
    the input box title and the default output file name.
    
    The saved state includes context line numbers and input box coordinates.
    Environments are saved as "$HOME\.PowerShelf\Add-Debugger.clixml".
    
    'Add-Debugger' is used by default.
    
    Required?                    false
    Position?                    named
    Default value                Add-Debugger
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```text
-WriteHost [<SwitchParameter>]
    Tells to use Write-Host and Out-Host for debugger output.
    
    Required?                    false
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```text
-ReadGui [<SwitchParameter>]
    Tells to use GUI input boxes for input.
    
    Required?                    true
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```text
-ReadHost [<SwitchParameter>]
    Tells to use Read-Host or PSReadLine for input.
    PSReadLine should be imported and configured beforehand.
    
    Required?                    true
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

## Examples

```text
-------------------------- EXAMPLE 1 --------------------------
# How to debug bare runspaces
$script = {
	Add-Debugger  # add debugger with default options
	Wait-Debugger # use hardcoded or other breakpoints
}
$ps = [PowerShell]::Create().AddScript('& $args[0]').AddArgument($script)
$null = $ps.BeginInvoke()
```

## Links

```text
https://github.com/nightroman/PowerShelf
```
