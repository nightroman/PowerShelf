# Invoke-Environment.ps1

```
Invokes a command and imports its environment variables.
Author: Roman Kuzmin (inspired by Lee Holmes's Invoke-CmdScript.ps1)
```

## Syntax

```
Invoke-Environment.ps1 [-Command] String [-Output] [-Force]
```

```
Invoke-Environment.ps1 -File String [-Arguments String[]] [-Output] [-Force]
```

## Description

```
It invokes the specified command or batch file with arguments and imports
its result environment variables to the current PowerShell session.

Command output is discarded by default, use the switch Output to enable it.
You may check for $LASTEXITCODE unless the switch Force is specified.
```

## Parameters

```
-Command <String>
    Specifies the entire command including the batch file and parameters.
    This string is passed in `cmd /c` as it is. Mind quotes for paths and
    arguments with spaces and special characters. Do not use redirection.
    
    Required?                    true
    Position?                    1
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```
-File <String>
    Specifies the batch file path.
    
    Required?                    true
    Position?                    named
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```
-Arguments <String[]>
    With File, specifies its arguments. Arguments with spaces are quoted.
    In the batch file, you may unquote them as %~1, %~2, etc.
    Other special characters are not treated.
    
    Required?                    false
    Position?                    named
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```
-Output [<SwitchParameter>]
    Tells to collect and return the command output.
    
    Required?                    false
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```
-Force [<SwitchParameter>]
    Tells to import variables even if the command exit code is not 0.
    
    Required?                    false
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

## Inputs

```
None. Use the script parameters.
```

## Outputs

```
With Output, the command output.
```

## Examples

```
-------------------------- EXAMPLE 1 --------------------------
PS>
# Invoke vsvars32 and import variables even if exit code is not 0
Invoke-Environment '"%VS100COMNTOOLS%\vsvars32.bat"' -Force

# Invoke vsvars32 as file and get its output
Invoke-Environment -File $env:VS100COMNTOOLS\vsvars32.bat -Output
```

## Links

```
https://github.com/nightroman/PowerShelf
```
