# Open-Url.ps1

```
Creates and opens HTML navigating to URL.
```

## Syntax

```
Open-Url.ps1 [-Uri] Uri [-File String]
```

## Description

```
This command works around potential issues with complex URLs when
Start-Process and other methods may fail. It opens a new HTML file
navigating to the specified URL (assuming .html opens the browser).
```

## Parameters

```
-Uri <Uri>
    URL to open in .html associated browser.
    
    Required?                    true
    Position?                    1
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```
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

```
https://github.com/nightroman/PowerShelf
```
