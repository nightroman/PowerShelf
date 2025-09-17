# Save-NuGetTool.ps1

```text
Downloads a NuGet package and extracts /tools.
Author: Roman Kuzmin
```

## Syntax

```text
Save-NuGetTool.ps1 [[-PackageId] Object]
```

## Description

```text
The command downloads "PackageId.zip" from the NuGet Gallery to the current
location and extracts "/tools" as the directory "PackageId". If these items
exist remove them manually or use another location. "PackageId.zip" is
removed after successful unzipping.
```

## Parameters

```text
-PackageId <Object>
    Specifies the package ID.
    
    Required?                    false
    Position?                    1
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

## Links

```text
https://github.com/nightroman/PowerShelf
```
