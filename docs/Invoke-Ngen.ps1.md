# Invoke-Ngen.ps1

```text
Invokes the Native Image Generator tool (ngen.exe).
```

## Syntax

```text
Invoke-Ngen.ps1
```

```text
Invoke-Ngen.ps1 -Alias
```

```text
Invoke-Ngen.ps1 -Update [-Queue]
```

```text
Invoke-Ngen.ps1 -Current [-NoDependencies]
```

```text
Invoke-Ngen.ps1 -Directory String [-Recurse] [-NoDependencies]
```

## Description

```text
Use this tool to improve performance of managed applications. It creates
native images and installs them into the native image cache. The runtime
can use native images from the cache instead of using the just-in-time
(JIT) compiler to compile original assemblies.

The tool may print various errors "Failed to load dependency..." and etc.
They are not necessarily problems, the tool still improves what it can.
```

## Parameters

```text
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

```text
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

```text
-Queue [<SwitchParameter>]
    Tells to queue updates for the ngen service. It is used with -Update.
    
    Required?                    false
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```text
-Current [<SwitchParameter>]
    Tells to generate native images for the currently loaded app assemblies.
    Of course, it is a PowerShell hosting app, either console or another host.
    
    Required?                    true
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```text
-Directory <String>
    Specifies the directory and tells to generate native images for its
    exe and dll files.
    
    Required?                    true
    Position?                    named
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```text
-Recurse [<SwitchParameter>]
    With -Directory, tells to include child directories and sets
    -NoDependencies to true.
    
    Required?                    false
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```text
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

```text
-------------------------- EXAMPLE 1 --------------------------


# update native images in the local computer cache
Invoke-Ngen -Update

# generate images for exe and dll from a directory
Invoke-Ngen -Directory . -Recurse
```

## Links

```text
https://docs.microsoft.com/en-us/dotnet/framework/tools/ngen-exe-native-image-generator
https://github.com/nightroman/PowerShelf
```
