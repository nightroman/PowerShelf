# Show-GraphQLVoyager.ps1

```
Shows GraphQL schema using https://github.com/graphql-kit/graphql-voyager
```

## Syntax

```
Show-GraphQLVoyager.ps1 [-Schema] String [[-RootType] String] [-Output String] [-HideDocs] [-HideLeafFields] [-HideSettings] [-HideRoot] [-ShowDeprecated] [-ShowRelay] [-SortByAlphabet]
```

## Description

```
This command generates and opens HTML which renders GraphQL Voyager
with the specified GraphQL schema file or URL for introspection and
several display options.
```

## Parameters

```
-Schema <String>
    Specifies the GraphQL schema file or URL for introspection.
    
    Required?                    true
    Position?                    1
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```
-RootType <String>
    The root type name.
    
    Required?                    false
    Position?                    2
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```
-Output <String>
    Tells to output HTML to the specified file. If this parameter is
    omitted then the temp file "GraphQLVoyager.html" is used and on
    Windows automatically opened.
    
    Required?                    false
    Position?                    named
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```
-HideDocs [<SwitchParameter>]
    Tells to hide the docs sidebar.
    
    Required?                    false
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```
-HideLeafFields [<SwitchParameter>]
    Tells to hide all scalars and enums.
    
    Required?                    false
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```
-HideSettings [<SwitchParameter>]
    Tells to hide the settings panel.
    
    Required?                    false
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```
-HideRoot [<SwitchParameter>]
    Tells to hide the root type.
    
    Required?                    false
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```
-ShowDeprecated [<SwitchParameter>]
    Tells to show deprecated entities.
    
    Required?                    false
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```
-ShowRelay [<SwitchParameter>]
    Tells to show relay types literally.
    
    Required?                    false
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```
-SortByAlphabet [<SwitchParameter>]
    Tells to sort type fields by alphabet.
    
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
