# Invoke-Ngen.ps1

```
Invokes the Native Image Generator tool (ngen.exe).
```

## Syntax

```
Invoke-Ngen.ps1
```

```
Invoke-Ngen.ps1 -Alias
```

```
Invoke-Ngen.ps1 -Update [-Queue]
```

```
Invoke-Ngen.ps1 -Current [-NoDependencies]
```

```
Invoke-Ngen.ps1 -Directory String [-Recurse] [-NoDependencies]
```

## Description

```
Use this tool to improve performance of managed applications. It creates
native images and installs them into the native image cache. The runtime
can use native images from the cache instead of using the just-in-time
(JIT) compiler to compile original assemblies.

The tool may print various errors "Failed to load dependency..." and etc.
They are not necessarily problems, the tool still improves what it can.
```

## Parameters

```
-Alias [<SwitchParameter>]
    Tells to set the alias `ngen` in the calling scope.
    Use the alias in order to call the tool directly.
    Example:
    	ngen /?
    
    Required?                    true
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```
-Update [<SwitchParameter>]
    Tells to update native images that have become invalid. Without -Queue
    this operation may take several minutes. But you may see some improved
    performance immediately after that.
    
    If -Queue is specified, the updates are queued for the ngen service and
    the command finishes immediately. Updates run when the computer is idle.
    
    Required?                    true
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```
-Queue [<SwitchParameter>]
    Tells to queue updates for the ngen service. It is used with -Update.
    
    Required?                    false
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```
-Current [<SwitchParameter>]
    Tells to generate native images for the currently loaded app assemblies.
    Of course, it is a PowerShell hosting app, either console or another host.
    
    Required?                    true
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```
-Directory <String>
    Specifies the directory and tells to generate native images for its
    exe and dll files.
    
    Required?                    true
    Position?                    named
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```
-Recurse [<SwitchParameter>]
    With -Directory, tells to include child directories and sets
    -NoDependencies to true.
    
    Required?                    false
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```
-NoDependencies [<SwitchParameter>]
    With -Directory or -Current, tells to generate the minimum number of
    native images required. With -Recurse, tt is ignored and used as true.
    
    Required?                    false
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

## Examples

```
-------------------------- EXAMPLE 1 --------------------------


# update native images in the local computer cache
Invoke-Ngen -Update

# generate images for exe and dll from a directory
Invoke-Ngen -Directory . -Recurse
```

## Links

```
https://docs.microsoft.com/en-us/dotnet/framework/tools/ngen-exe-native-image-generator
https://github.com/nightroman/PowerShelf
```
