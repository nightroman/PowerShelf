@pwsh -NoProfile -Command "if (Get-Module PSReadline) {Remove-Module PSReadline}; Add-Debugger -ReadHost; Test-Debugger"
