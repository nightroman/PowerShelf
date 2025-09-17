# Export-Binary.ps1

```
Exports objects using binary serialization.
Author: Roman Kuzmin
```

## Syntax

```
Export-Binary.ps1 [-Path] String [[-InputObject] Object] [-Append]
```

## Description

```
This command serializes objects to the specified binary file. Together with
Import-Binary.ps1 it is used for data persistence between sessions.

Objects should be serializable. The command stops on any serialization
issues and in this case the output file is not complete, more likely.
Nevertheless, objects written before an error can be recovered by
Import-Binary.ps1 with ErrorAction set to Continue or Ignore.

Note that in PowerShell V2 PSObject is not serializable.
```

## Parameters

```
-Path <String>
    Specifies the path to the output file.
    
    Required?                    true
    Position?                    1
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```
-InputObject <Object>
    Specifies the objects to export. Use it either as the parameter for a
    single object or pipe several objects to the command.
    
    Required?                    false
    Position?                    2
    Accept pipeline input?       true (ByValue)
    Accept wildcard characters?  false
```

```
-Append [<SwitchParameter>]
    Tells to add the output to the end of the specified file.
    
    Required?                    false
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

## Inputs

```
Objects to be serialized.
```

## Outputs

```
None.
```

## Links

```
https://github.com/nightroman/PowerShelf
Import-Binary.ps1
```
