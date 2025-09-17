# Show-GraphQLVoyager.ps1

```text
Shows GraphQL schema using https://github.com/graphql-kit/graphql-voyager
```

## Syntax

```text
Show-GraphQLVoyager.ps1 [-Schema] String [[-RootType] String] [-Output String] [-HideDocs] [-HideLeafFields] [-HideSettings] [-HideRoot] [-ShowDeprecated] [-ShowRelay] [-SortByAlphabet]
```

## Description

```text
This command generates and opens HTML which renders GraphQL Voyager
with the specified GraphQL schema file or URL for introspection and
several display options.
```

## Parameters

```text
-Schema <String>
    Specifies the GraphQL schema file or URL for introspection.
    
    Required?                    true
    Position?                    1
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```text
-RootType <String>
    The root type name.
    
    Required?                    false
    Position?                    2
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```text
-Output <String>
    Tells to output HTML to the specified file. If this parameter is
    omitted then the temp file "GraphQLVoyager.html" is used and on
    Windows automatically opened.
    
    Required?                    false
    Position?                    named
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```text
-HideDocs [<SwitchParameter>]
    Tells to hide the docs sidebar.
    
    Required?                    false
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```text
-HideLeafFields [<SwitchParameter>]
    Tells to hide all scalars and enums.
    
    Required?                    false
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```text
-HideSettings [<SwitchParameter>]
    Tells to hide the settings panel.
    
    Required?                    false
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```text
-HideRoot [<SwitchParameter>]
    Tells to hide the root type.
    
    Required?                    false
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```text
-ShowDeprecated [<SwitchParameter>]
    Tells to show deprecated entities.
    
    Required?                    false
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```text
-ShowRelay [<SwitchParameter>]
    Tells to show relay types literally.
    
    Required?                    false
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```text
-SortByAlphabet [<SwitchParameter>]
    Tells to sort type fields by alphabet.
    
    Required?                    false
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

## Links

```text
https://github.com/nightroman/PowerShelf
```
