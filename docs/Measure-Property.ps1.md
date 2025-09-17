# Measure-Property.ps1

```
Counts properties grouped by names and types.
Author: Roman Kuzmin
```

## Syntax

```
Measure-Property.ps1 [-CaseSensitive] [-DictionaryProperty]
```

## Description

```
The script counts objects grouped by types and their properties or entries
grouped by names and types. Input objects should be piped to the script.
```

## Parameters

```
-CaseSensitive [<SwitchParameter>]
    Tells to process names as case sensitive.
    
    Required?                    false
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```
-DictionaryProperty [<SwitchParameter>]
    Tells to count dictionary properties. By default dictionaries are treated
    as property bags, i.e. key/value pairs are counted instead of properties.
    
    Required?                    false
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

## Inputs

```
Objects which properties or entries are to be counted.
```

## Outputs

```
Custom objects with properties Name, Type, and Count.
```

## Links

```
https://github.com/nightroman/PowerShelf
```
