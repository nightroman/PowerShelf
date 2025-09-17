# Set-Env.ps1

```text
Sets or removes environment variables (Windows User/Machine/Process).
Author: Roman Kuzmin
```

## Syntax

```text
Set-Env.ps1 [-Name] String [[-Value] String] [[-Target] String]
```

## Description

```text
This command sets the current process environment and sets the current User
or local Machine environment, depending on Target (default: User).
```

## Parameters

```text
-Name <String>
    Specifies the environment variable name.
    
    Required?                    true
    Position?                    1
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```text
-Value <String>
    Specifies the environment variable value.
    If it is omitted or empty then the variable is removed.
    
    Required?                    false
    Position?                    2
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```text
-Target <String>
    
    Required?                    false
    Position?                    3
    Default value                User
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

## Links

```text
Set-Env.ArgumentCompleters.ps1
https://github.com/nightroman/PowerShelf
```
