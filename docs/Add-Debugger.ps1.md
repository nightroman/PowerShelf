# Add-Debugger.ps1

```text
Debugger for PowerShell hosts with no own debuggers.
```

## Syntax

```text
Add-Debugger.ps1 [[-Path] String] [-Context Int32[]] [-Env String] [-WriteHost]
```

```text
Add-Debugger.ps1 [[-Path] String] [-Context Int32[]] [-Env String] [-WriteHost] -ReadGui
```

```text
Add-Debugger.ps1 [[-Path] String] [-Context Int32[]] [-Env String] [-WriteHost] -ReadHost
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

Env data are saved as "HKCU\Software\VB and VBA Program Settings\Add-Debugger\<env>".
Env "$shared" keeps common data, users may change:

- "watch_app", "watch_args"

	Watcher application and its arguments.
	(1) "watch_app" may be "pwsh" or "powershell" with empty "watch_args".
	(2) "watch_app" may be "wt" with "watch_args" ending with "pwsh" or "powershell":

		watch_app  : wt.exe
		watch_args : --window -1 --pos 0,0 --size 80,50 --title Debug pwsh.exe

- "history"

	History of typed PowerShell statements (automatically updated 50 last items).
```

## Parameters

```text
-Path <String>
    Specifies the file used for debugger output. A separate console is
    used for watching its tail. Do not let the file to grow too large.
    Invoke `new` when watching gets slower.
    
    "$env:TEMP\$Env.log" is used by default.
    The default file is deleted before debugging.
    
    Required?                    false
    Position?                    1
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```text
-Context <Int32[]>
    One or two integers, shown line counts before and after the current.
    
    Default: @(4, 4)
    
    Required?                    false
    Position?                    named
    Default value                @(4, 4)
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```text
-Env <String>
    Specifies the environment name for saving the state. It is also used as
    the input box title and the default output file name.
    
    The saved state includes context line numbers and input box coordinates.
    
    Default: "Add-Debugger"
    
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
https://github.com/nightroman/PowerShelf/blob/main/docs/Add-Debugger.ps1.md
```
