# Expand-Diff.ps1

```
Expands git diff into directories "a" and "b".
```

## Syntax

```
Expand-Diff.ps1 [-Diff] String [[-Root] String]
```

## Description

```
The script is designed for diff and patch files created by git. It expands
the specified diff file into directories "a" and "b" (original and changes)
with pieces of files stored in the diff.

Then you can use your diff tool of choice in order to compare the
directories "a" and "b", i.e. to visualize the original diff file.

The following diff lines are recognized and processed:

	--- a/... | "a/..." | /dev/null ~ file "a"
	+++ b/... | "b/..." | /dev/null ~ file "b"
	@@... ~ chunk header
	 ... ~ common line
	-... ~ "a" line
	+... ~ "b" line

Other lines are ignored.
```

## Parameters

```
-Diff <String>
    Specifies the diff file path.
    
    Required?                    true
    Position?                    1
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```
-Root <String>
    Specifies the output directory where the directories "a" and "b" will
    be created. The script fails if "a" or "b" exists in this directory.
    If this parameter is omitted then the current location is used.
    
    Required?                    false
    Position?                    2
    Default value                .
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

## Links

```
https://github.com/nightroman/PowerShelf
```
