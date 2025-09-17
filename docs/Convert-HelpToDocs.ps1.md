# Convert-HelpToDocs.ps1

```
Converts command help to markdown docs.
Author: Roman Kuzmin
```

## Syntax

```
Convert-HelpToDocs.ps1 [-Command] String [[-OutFile] String]
```

## Description

```
It gets and converts the command help to markdown.

Default output is markdown text.
Use OutFile to save it.
```

## Parameters

```
-Command <String>
    The command name.
    
    Required?                    true
    Position?                    1
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```
-OutFile <String>
    Optional output file path.
    
    Required?                    false
    Position?                    2
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

## Links

```
https://github.com/nightroman/PowerShelf
```
