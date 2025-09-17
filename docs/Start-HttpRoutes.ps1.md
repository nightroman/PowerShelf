# Start-HttpRoutes.ps1

```
Starts HTTP server with routing script blocks.
```

## Syntax

```
Start-HttpRoutes.ps1 [-Prefix] String [[-Routes] IDictionary]
```

## Description

```
Starts HTTP server with routing script blocks.

Route handler helper commands and variables:

	Read-Content
	Get-Headers
	Get-Query

	$Context  [System.Net.HttpListenerContext]
	$Request  [System.Net.HttpListenerRequest]
	$Response [System.Net.HttpListenerResponse]

	In addition to the parameter Routes, or even instead of it, routes may
	be defined as conventional functions named like HttpRoute-*, providing
	their route tags as CmdletBinding DefaultParameterSetName:

		function HttpRoute-Show {
			[CmdletBinding(DefaultParameterSetName = 'POST /show')] param()
			...
		}
```

## Parameters

```
-Prefix <String>
    HttpListener prefix.
    Example:
    	http://localhost:8080/
    	http://127.0.0.1:8080/
    
    Required?                    true
    Position?                    1
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```
-Routes <IDictionary>
    Route tags and handlers, hashtable or dictionary.
    
    Keys are route tags:
    
    	GET /
    	POST /user
    	POST /test/*
    
    Values are route request handlers, script blocks.
    
    Required?                    false
    Position?                    2
    Default value                [ordered]@{}
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

## Links

```
https://github.com/nightroman/PowerShelf
```
