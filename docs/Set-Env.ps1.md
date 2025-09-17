# Set-Env.ps1

```
Sets or removes environment variables (Windows User/Machine/Process).
Author: Roman Kuzmin
```

## Syntax

```
Set-Env.ps1 [-Name] String [[-Value] String] [[-Target] String]
```

## Description

```
This command sets the current process environment and sets the current User
or local Machine environment, depending on Target (default: User).
```

## Parameters

```
-Name <String>
    Specifies the environment variable name.
    
    Required?                    true
    Position?                    1
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```
-Value <String>
    Specifies the environment variable value.
    If it is omitted or empty then the variable is removed.
    
    Required?                    false
    Position?                    2
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```
-Target <String>
    
    Required?                    false
    Position?                    3
    Default value                User
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

## Links

```
Set-Env.ArgumentCompleters.ps1
https://github.com/nightroman/PowerShelf
```
