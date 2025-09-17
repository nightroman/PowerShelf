# Assert-SameFile.ps1

```text
Compares the sample and result files or texts.
```

## Syntax

```text
Assert-SameFile.ps1 [[-Sample] Object] [[-Result] Object] [[-View] Object] [-Fail] [-Text]
```

## Description

```text
This script automates one typical test scenario, it compares the sample and
result files and performs copy and view operations if the sample is missing
(nor yet created) or the result is different (potentially valid but changed
so that the sample may have to be updated after review).

If the result is missing then the test fails. If the sample is missing then
a warning is written and the sample is created as a copy of the result. The
target directory is also created if it does not exist.

If files are different then the test either fails or, if View is specified
and Fail is not, invokes View, writes a warning, and then prompts to update
the sample file.

File comparison is done via MD5 hashes, it is fast and suitable for large
files. But there is a tiny chance that file differences are not detected.
```

## Parameters

```text
-Sample <Object>
    Specifies the sample file path. If it does not exist then it is
    created as a copy of the result.
    
    With Text, specifies strings to be joined and compared with Result.
    
    Required?                    false
    Position?                    1
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```text
-Result <Object>
    Specifies the result file path. The file must exist.
    
    With Text, specifies strings to be joined and compared with Sample.
    
    Required?                    false
    Position?                    2
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```text
-View <Object>
    Specifies a command invoked when the files are different. It is an
    application name or a script block. The arguments are file paths.
    
    Required?                    false
    Position?                    3
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```text
-Fail [<SwitchParameter>]
    Tells to fail on differences even when View is specified.
    
    Required?                    false
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```text
-Text [<SwitchParameter>]
    Tells that Sample and Result are strings to compare as text ignoring
    line ends. If they differ and View is set then View uses temp files
    Sample-{n}.txt and Result-{n}.txt with saved texts.
    
    Required?                    false
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

## Examples

```text
-------------------------- EXAMPLE 1 --------------------------
PS> Assert-SameFile Sample.log Result.log Merge.exe

This command compares Sample.log and Result.log at the current location and
uses Merge.exe for viewing differences (Merge.exe and file paths are passed
in Start-Process).
```

```text
-------------------------- EXAMPLE 2 --------------------------
PS> Assert-SameFile Sample.log Result.log {git diff --no-index $args[0] $args[1]}

This command uses git in order to view changes. git requires more arguments
than Merge.exe above, so that the proper script block is used as a command.
```

## Links

```text
https://github.com/nightroman/PowerShelf
```
