# Open-Url.ps1

```text
Creates and opens HTML navigating to URL.
```

## Syntax

```text
Open-Url.ps1 [-Uri] Uri [-File String]
```

## Description

```text
This command works around potential issues with complex URLs when
Start-Process and other methods may fail. It opens a new HTML file
navigating to the specified URL (assuming .html opens the browser).
```

## Parameters

```text
-Uri <Uri>
    URL to open in .html associated browser.
    
    Required?                    true
    Position?                    1
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```text
-File <String>
    New HTML file to create and open.
    Default: "Temp:\Open-Url.html"
    
    Required?                    false
    Position?                    named
    Default value                Temp:\Open-Url.html
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

## Links

```text
https://github.com/nightroman/PowerShelf
```
