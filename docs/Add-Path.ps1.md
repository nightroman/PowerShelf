# Add-Path.ps1

```text
Adds a directory to an environment path variable.
Author: Roman Kuzmin
```

## Syntax

```text
Add-Path.ps1 [[-Path] String[]] [[-Name] String]
```

## Description

```text
The script resolves the specified path, checks that the directory exists,
and adds the path to an environment variable if it is not there yet. The
changes are effective for the current process.
```

## Parameters

```text
-Path <String[]>
    Specifies the path to be added.
    Default is the current location.
    
    Required?                    false
    Position?                    1
    Default value                .
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```text
-Name <String>
    Specifies the environment variable to be updated.
    Default is 'PATH'.
    
    Required?                    false
    Position?                    2
    Default value                PATH
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
PS> Add-Path

Adds the current location to the system path.
```

```text
-------------------------- EXAMPLE 2 --------------------------
PS> Add-Path TestModules PSModulePath

Adds TestModules to the PowerShell module path.
```

## Links

```text
https://github.com/nightroman/PowerShelf
```
