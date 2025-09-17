# Add-Path.ps1

```
Adds a directory to an environment path variable.
Author: Roman Kuzmin
```

## Syntax

```
Add-Path.ps1 [[-Path] String[]] [[-Name] String]
```

## Description

```
The script resolves the specified path, checks that the directory exists,
and adds the path to an environment variable if it is not there yet. The
changes are effective for the current process.
```

## Parameters

```
-Path <String[]>
    Specifies the path to be added.
    Default is the current location.
    
    Required?                    false
    Position?                    1
    Default value                .
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```
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
PS> Add-Path

Adds the current location to the system path.
```

```
-------------------------- EXAMPLE 2 --------------------------
PS> Add-Path TestModules PSModulePath

Adds TestModules to the PowerShell module path.
```

## Links

```
https://github.com/nightroman/PowerShelf
```
