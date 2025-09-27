# Assert-GitBranchClean.ps1

```text
Asserts current branch name and clean status.
Author: Roman Kuzmin
```

## Syntax

```text
Assert-GitBranchClean.ps1 [[-Branch] String]
```

## Description

```text
It fails on unexpected current branch name or not committed files.
Requires git in the path.
```

## Parameters

```text
-Branch <String>
    The expected current branch name.
    Default: main
    
    Required?                    false
    Position?                    1
    Default value                main
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

## Links

```text
https://github.com/nightroman/PowerShelf
```
