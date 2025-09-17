# Save-NuGetTool.ps1

```
Downloads a NuGet package and extracts /tools.
Author: Roman Kuzmin
```

## Syntax

```
Save-NuGetTool.ps1 [[-PackageId] Object]
```

## Description

```
The command downloads "PackageId.zip" from the NuGet Gallery to the current
location and extracts "/tools" as the directory "PackageId". If these items
exist remove them manually or use another location. "PackageId.zip" is
removed after successful unzipping.
```

## Parameters

```
-PackageId <Object>
    Specifies the package ID.
    
    Required?                    false
    Position?                    1
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

## Links

```
https://github.com/nightroman/PowerShelf
```
