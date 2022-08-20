# Add-Debugger notes

## AddDebuggerHelpers

The name `AddDebuggerHelpers` is slightly different from `AddDebuggerHelper`,
just in case. The latter is used in PowerShellFar.

Static class did not work well with several debuggers, e.g. in PowerShellFar
when a far task test with Add-Debugger is started with another Add-Debugger
for stepping.

## Error output

```powershell
Write-Debugger $(if ($_.InvocationInfo.ScriptName) {$_} else {"ERROR: $_"})
```

`$_` - full error with formatting and colors.

`"ERROR: $_"` - just text, that's why we emphasize with `ERROR:`.

**Terminating and non terminating errors**

Terminating errors are handled in catch as usual.

For non terminating errors we watch `$global:Error` for new errors and show the
last error. -- Can we improve this?

`global` is just in case, I remember some issues in far tasks without it.
