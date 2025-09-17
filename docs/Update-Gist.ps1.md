# Update-Gist.ps1

```
Updates or creates a gist file using Invoke-RestMethod.
Author: Roman Kuzmin
```

## Syntax

```
Update-Gist.ps1 [-FileName] String [[-GistId] String] [[-GitHubToken] String] [-Show]
```

## Description

```
The script updates or creates a text file in the existing GitHub gist.

See also Submit-Gist.ps1 which has its pros and cons.
```

## Parameters

```
-FileName <String>
    Specifies the file to be updated or created in the gist.
    
    Required?                    true
    Position?                    1
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```
-GistId <String>
    The existing gist ID. If it is not specified then the script searches
    for a gist URL in the file, the first matching URL is used for the ID.
    The expected URL forms:
    	https://gist.github.com/gist-id
    	https://gist.github.com/user/gist-id
    
    Required?                    false
    Position?                    2
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```
-GitHubToken <String>
    The GitHub token, default is $env:GITHUB_TOKEN.
    If it is not defined then the prompt is shown.
    
    Required?                    false
    Position?                    3
    Default value                $env:GITHUB_TOKEN
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```
-Show [<SwitchParameter>]
    Tells to show the gist web page after updating.
    
    Required?                    false
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

## Inputs

```
None.
```

## Outputs

```
None.
```

## Links

```
https://docs.github.com/en/rest/reference/gists
https://github.com/nightroman/PowerShelf
```
