# Sync-Directory.ps1

```text
Syncs two directories with some interaction.
Author: Roman Kuzmin
```

## Syntax

```text
Sync-Directory.ps1 [-Directory1] String [-Directory2] String [-Arguments String[]]
```

## Description

```text
Requires:
	Robocopy.exe, Windows utility since Windows Vista
	PowerShell host supporting Write-Host with colors
Optional:
	%MERGE%, directory comparison application

The script automates one simple scenario. Some directory exists in several
places (home, work, removable drive, backup copy, etc.) but changes in it
are normally done in one of them and they should be propagated to another.
The script visualizes these changes and tries to determine which directory
is newer and should be mirrored.

It is possible to skip the suggested operation and tell to mirror in the
opposite direction or start an external directory comparison application.

The tool is simple but it saves time when such operations are repeatedly
performed manually. Besides it may help to avoids mistakes and data loss
(like copying in a wrong direction).
```

## Parameters

```text
-Directory1 <String>
    Specifies the first directory.
    If it is missing then the second should exist.
    
    Required?                    true
    Position?                    2
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```text
-Directory2 <String>
    Specifies the second directory.
    If it is missing then the first should exist.
    
    Required?                    true
    Position?                    3
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```text
-Arguments <String[]>
    Additional Robocopy arguments. Example:
    ... -Arguments /XD, bin, obj, /XF, *.tmp, *.bak
    
    Required?                    false
    Position?                    named
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

## Examples

```text
-------------------------- EXAMPLE 1 --------------------------
PS>
# Sync the current directory with its conventional backup
# e.g. C:\Scripts\Project1 -> C:\Backup\Scripts\Project1

Sync-Directory $pwd ($pwd -replace '^(.:)', '$1\Backup')
```

## Links

```text
https://github.com/nightroman/PowerShelf
```
