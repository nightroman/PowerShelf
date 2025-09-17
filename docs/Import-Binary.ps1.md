# Import-Binary.ps1

```text
Imports objects using binary serialization.
Author: Roman Kuzmin
```

## Syntax

```text
Import-Binary.ps1 [-Path] Object
```

## Description

```text
This command de-serializes objects from the specified binary file. Together
with Export-Binary.ps1 it is used for data persistence between sessions.
```

## Parameters

```text
-Path <Object>
    Specifies the path to the input file.
    
    Required?                    true
    Position?                    1
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

## Links

```text
https://github.com/nightroman/PowerShelf
Export-Binary.ps1
```
