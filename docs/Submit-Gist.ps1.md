# Submit-Gist.ps1

```
Submits a file to its GitHub gist repository.
Author: Roman Kuzmin
```

## Syntax

```
Submit-Gist.ps1 [-FileName] String [[-GistId] String] [-Keep]
```

## Description

```
Requirements:
* The gist exists and you are the owner.
* Git client is installed, configured, and available in the path.
* Use PowerShell.exe, git may require some console based interaction.

The script uses the local gist repository $HOME\gist-{GistId}. If it does
not exist then it is cloned. Then the file is copied to this repository.
Then git `add`, `status`, `commit`, and `push` are invoked.

A just cloned local gist repository is removed after submission unless the
switch Keep is used. An existing local repository is not removed.

See also Update-Gist.ps1 which has its pros and cons.
```

## Parameters

```
-FileName <String>
    The file to be submitted (existing is updated, new is added).
    
    Required?                    true
    Position?                    1
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```
-GistId <String>
    The existing gist ID. If it is not specified then the script searches
    for a gist URL in the file, the first matching URL is used for the ID.
    The expected URL is either
    	https://gist.github.com/user/gist-id
    or
    	https://gist.github.com/gist-id
    
    Required?                    false
    Position?                    2
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```
-Keep [<SwitchParameter>]
    Tells to keep the local gist repository.
    
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
git output.
```

## Links

```
https://github.com/nightroman/PowerShelf
```
