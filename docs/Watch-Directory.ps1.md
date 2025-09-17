# Watch-Directory.ps1

```
File change watcher and handler.
Author: Roman Kuzmin
```

## Syntax

```
Watch-Directory.ps1 [-Path] String[] [[-Command] Object] [-Filter String] [-Include String] [-Exclude String] [-Recurse] [-TestSeconds Int32] [-WaitSeconds Int32]
```

## Description

```
The script watches for changed, created, deleted, and renamed files in the
given directories. On changes it invokes the specified command with change
info. It is a dictionary where keys are changed file paths, values are last
change types.

If the command is omitted then the script outputs change info as text.

The script works until it is forcedly stopped (Ctrl-C).
```

## Parameters

```
-Path <String[]>
    Specifies the watched directory paths.
    
    Required?                    true
    Position?                    2
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```
-Command <Object>
    Specifies the command to process changes.
    It may be a script block or a command name.
    
    Required?                    false
    Position?                    3
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```
-Filter <String>
    Simple and effective file system filter. Default *.*
    
    Required?                    false
    Position?                    named
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```
-Include <String>
    Inclusion regular expression pattern applied after Filter.
    
    Required?                    false
    Position?                    named
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```
-Exclude <String>
    Exclusion regular expression pattern applied after Filter.
    
    Required?                    false
    Position?                    named
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```
-Recurse [<SwitchParameter>]
    Tells to watch files in subdirectories as well.
    
    Required?                    false
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```
-TestSeconds <Int32>
    Time to sleep between checks for change events.
    
    Required?                    false
    Position?                    named
    Default value                5
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```
-WaitSeconds <Int32>
    Time to wait after the last change before processing.
    
    Required?                    false
    Position?                    named
    Default value                5
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

## Links

```
https://github.com/nightroman/PowerShelf
```
