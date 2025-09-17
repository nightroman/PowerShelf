# Convert-HelpToDocs.ps1

```text
Converts command help to markdown docs.
Author: Roman Kuzmin
```

## Syntax

```text
Convert-HelpToDocs.ps1 [-Command] String [[-OutFile] String]
```

## Description

```text
It gets and converts the command help to markdown.

Default output is markdown text.
Use OutFile to save it.
```

## Parameters

```text
-Command <String>
    The command name.
    
    Required?                    true
    Position?                    1
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```text
-OutFile <String>
    Optional output file path.
    
    Required?                    false
    Position?                    2
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

## Links

```text
https://github.com/nightroman/PowerShelf
```
