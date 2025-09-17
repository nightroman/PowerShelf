# Measure-Command2.ps1

```text
Measure-Command with several iterations and progress.
Author: Roman Kuzmin
```

## Syntax

```text
Measure-Command2.ps1 [-Expression] ScriptBlock[] [[-Count] Int32] [-NoProgress] [-NoEscape] [-Test]
```

## Description

```text
The script is for measuring duration of fast expressions. In order to get a
more reliable result it invokes an expression several times and returns the
average. Unlike Measure-Command, it returns milliseconds, not a time span.

By default the script shows the progress with some current information and
allows immediate return of the current result on pressed [Escape].

Use the switch Test in order to invoke the expression once before timing
and show the result, e.g. simply to be sure that the expression works as
expected.

The script may not work with expressions using variables with peculiar
names like -*, e.g. ${-MyVar}. Such variables are used internally.
```

## Parameters

```text
-Expression <ScriptBlock[]>
    Specifies one or more expressions being invoked repeatedly.
    
    Required?                    true
    Position?                    1
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```text
-Count <Int32>
    Number of iterations. The default is 1000.
    
    Required?                    false
    Position?                    2
    Default value                1000
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```text
-NoProgress [<SwitchParameter>]
    Tells to not show the progress messages.
    
    Required?                    false
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```text
-NoEscape [<SwitchParameter>]
    Tells to not return on pressed [Escape].
    
    Required?                    false
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

```text
-Test [<SwitchParameter>]
    Tells to invoke once before timing.
    The result is written to the output.
    
    Required?                    false
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

## Inputs

```text
None. Use the script parameters.
```

## Outputs

```text
Average duration in milliseconds.
It comes after Test output, if any.
```

## Links

```text
https://github.com/nightroman/PowerShelf
```
