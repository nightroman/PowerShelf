# Update-ReadmeIndex.ps1

```text
Updates README index from content directories.
Author: Roman Kuzmin
```

## Syntax

```text
Update-ReadmeIndex.ps1 [-Content] String [-Root String] [-Depth Int32] [-Descending] [-NoWarning] [-Skip ScriptBlock]
```

## Description

```text
The command scans the contents recursively, finds README.md files and
builds the index from their first line headings in the root README.md.

The generated list with links is inserted into the root README.md.
The index start/end marks are defined by the HTML comments like:
given $Content='docs', marks are '<!--docs-->'.
```

## Parameters

```text
-Content <String>
    Specifies the directory to scan with the path relative to root.
    Use '/' as directory separators if it is not the top directory.
    
    Required?                    true
    Position?                    1
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```text
-Root <String>
    Specifies the root directory with README.md to be updated.
    The typical use case is a git repository root.
    Default: the current location
    
    Required?                    false
    Position?                    named
    Default value                .
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```text
-Depth <Int32>
    Specifies the recursive scan depth.
    Default: 0, just top directories.
    
    Required?                    false
    Position?                    named
    Default value                0
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```text
-Descending [<SwitchParameter>]
    Tells to sort top directories descending.
    
    Required?                    false
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```text
-NoWarning [<SwitchParameter>]
    Tells not to write warnings about no README.
    
    Required?                    false
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```text
-Skip <ScriptBlock>
    The script returning true for the directories to skip.
    Argument 1: directory path like $Content[/dir1[/...]]
    
    Required?                    false
    Position?                    named
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

## Links

```text
Example: https://github.com/nightroman/PowerShellTraps
https://github.com/nightroman/PowerShelf
```
