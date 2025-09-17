# Show-SolutionDgml.ps1

```
Generates and shows the solution project graph.
```

## Syntax

```
Show-SolutionDgml.ps1 [[-SolutionPath] String] [[-Exclude] String[]] [-JustProject] [-JustSolution]
```

## Description

```
For the given solution, the script generates project graph with project
reference links defined in project files and build order links defined
in the solution. Then the generated DGML is opened by the associated
program, normally Visual Studio.

For viewing in Visual Studio ensure:
- Individual components \ Code tools \ DGML editor
```

## Parameters

```
-SolutionPath <String>
    Specifies the solution path. If it is omitted or empty then the *.sln
    file in the current location is used, there must be one such file.
    
    Required?                    false
    Position?                    1
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```
-Exclude <String[]>
    Specifies the projects to exclude. Wilcards are supported.
    The patterns should match project names without extensions.
    
    Required?                    false
    Position?                    2
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```
-JustProject [<SwitchParameter>]
    Tells to show just references defined in project files and ignore build
    order dependencies in the solution.
    
    Required?                    false
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```
-JustSolution [<SwitchParameter>]
    Tells to show just build order dependencies defined in the solution and
    ignore references in project files.
    
    Required?                    false
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

## Links

```
https://github.com/nightroman/PowerShelf
```
