<#PSScriptInfo
.VERSION 1.2.0
.AUTHOR Roman Kuzmin
.COPYRIGHT (c) Roman Kuzmin
.TAGS Debug
.GUID e187060e-ad39-425c-a6e3-b1e1e92ab59d
.LICENSEURI http://www.apache.org/licenses/LICENSE-2.0
.PROJECTURI https://github.com/nightroman/PowerShelf
#>

<#
.Synopsis
	Debugger for PowerShell hosts with no own debuggers.

.Description
	The script adds or replaces existing debugger in any PowerShell runspace.
	It is useful for hosts with no own debuggers, e.g. Visual Studio NuGet
	console ("Package Manager Host"), bare runspace host ("Default Host").
	And it may be used instead of existing debuggers ("ConsoleHost").

	The script is called at any moment when debugging is needed. To restore
	the original debuggers, invoke Restore-Debugger defined by Add-Debugger.

	For output of debug commands the script uses Out-Host or a file with a
	separate console started for watching its tail.

	For input the input box is used for typing PowerShell and debugger
	commands. Specify the switch ReadHost for using Read-Host instead.

	PowerShell commands are invoked in a child of the current scope. In order
	to change current scope variables you would use `Set-Variable -Scope 1`.
	But the script recognises `$var = ...` and assigns in the proper scope.

.Parameter Path
		Specifies the output file used instead of Out-Host.
		A separate console is opened for watching its tail.

.Parameter Context
		Specifies the number of context source lines to show.

.Parameter XPos
		Horizontal position of the input box.

.Parameter YPos
		Vertical position of the input box.

.Parameter ReadHost
		Tells to use Read-Host instead of the input box.

.Inputs
	None
.Outputs
	None

.Example
	>
	How to debug terminating errors in a bare runspace. Use cases:
	- In .NET, the similar code is typical for invoking PowerShell.
	- In PowerShell, when using BeginInvoke() for background jobs.

	$ps = [PowerShell]::Create()
	$null = $ps.AddScript({
		# add debugger with file output
		Add-Debugger $env:TEMP\debug.log

		# trick: break on terminating errors
		$null = Set-PSBreakpoint -Variable StackTrace -Mode Write

		# from now on the debugger dialog is shown on errors
		# and a separate PowerShell output console is opened
		...
	})
	$ps.Invoke() # or BeginInvoke()

.Link
	https://github.com/nightroman/PowerShelf
#>

param(
	[Parameter()]
	[string]$Path,
	[int]$Context,
	[int]$XPos = -1,
	[int]$YPos = -1,
	[switch]$ReadHost
)

# All done?
if (Test-Path Variable:\_Debugger) {
	return
}

# Removes and gets debugger handlers.
function global:Remove-Debugger {
	$instance = [System.Management.Automation.Runspaces.Runspace]::DefaultRunspace.Debugger
	$type = [System.Management.Automation.Debugger]
	$e = $type.GetEvent('DebuggerStop')
	$v = $type.GetField('DebuggerStop', ([System.Reflection.BindingFlags]'NonPublic, Instance')).GetValue($instance)
	if ($v) {
		$handlers = $v.GetInvocationList()
		foreach($handler in $handlers) {
			$e.RemoveEventHandler($instance, $handler)
		}
		$handlers
	}
}

# Restores original debugger handlers.
function global:Restore-Debugger {
	if (!(Test-Path Variable:\_Debugger)) {
		return
	}
	$null = Remove-Debugger
	if ($_Debugger.Handlers) {
		foreach($handler in $_Debugger.Handlers) {
			[System.Management.Automation.Runspaces.Runspace]::DefaultRunspace.Debugger.add_DebuggerStop($handler)
		}
	}
	Remove-Variable _Debugger -Scope Global -Force
}

### Set debugger data.
$null = New-Variable -Name _Debugger -Scope Global -Description Add-Debugger.ps1 -Option ReadOnly -Value @{
	Path = $null
	Context = $Context
	XPos = [ref]$XPos
	YPos = [ref]$YPos
	Args = $null
	Watch = $false
	History = [System.Collections.ArrayList]@()
	Handlers = Remove-Debugger
	RefContext = [ref]0
	Action = '?'
	Match = $null
}

### Define how to write debugger output.
if ($Path) {
	$_Debugger.Path = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($Path)
	$_Debugger.Watch = $true
	function global:Write-Debugger {
		param($Data)
		[System.IO.File]::AppendAllText($_Debugger.Path, ($Data | Out-String))
		if ($_Debugger.Watch) {
			$_Debugger.Watch = $false
			Watch-Debugger $_Debugger.Path
		}
	}
}
else {
	function global:Write-Debugger {
		param($Data)
		$Data | Out-Host
	}
}

### Define how to reads debugger input.
if ($ReadHost) {
	function global:Read-Debugger {
		param($Prompt)
		Read-Host $Prompt
	}
}
else {
	function global:Read-Debugger {
		param($Prompt, $Default)
		Read-InputBox $Prompt Add-Debugger $Default Step Continue $_Debugger.XPos $_Debugger.YPos
	}
}

# Gets an input string from a dialog.
function global:Read-InputBox {
	param($Prompt, $Title, $Default, $Text1, $Text2, $XPos, $YPos)

	Add-Type -AssemblyName System.Windows.Forms, System.Drawing

	$form = New-Object System.Windows.Forms.Form
	$form.Text = $Title
	$form.TopMost = $true
	$form.Size = New-Object System.Drawing.Size(400, 132)
	$form.FormBorderStyle = 'FixedDialog'
	if ($XPos -and $YPos -and $XPos.Value -ge 0 -and $YPos.Value -ge 0) {
		$form.StartPosition = 'Manual'
		$form.Location = New-Object System.Drawing.Point($XPos.Value, $YPos.Value)
	}
	else {
		$form.StartPosition = 'CenterScreen'
	}

	$label = New-Object System.Windows.Forms.Label
	$label.Location = New-Object System.Drawing.Point(10, 10)
	$label.Size = New-Object System.Drawing.Size(380, 20)
	$label.Text = $Prompt
	$form.Controls.Add($label)

	$text = New-Object System.Windows.Forms.TextBox
	$text.Text = $Default
	$text.Location = New-Object System.Drawing.Point(10, 30)
	$text.Size = New-Object System.Drawing.Size(365, 20)
	$form.Controls.Add($text)

	$ok = New-Object System.Windows.Forms.Button
	$ok.Location = New-Object System.Drawing.Point(225, 60)
	$ok.Size = New-Object System.Drawing.Size(75, 23)
	$ok.Text = $Text1
	$ok.DialogResult = 'OK'
	$form.AcceptButton = $ok
	$form.Controls.Add($ok)

	$cancel = New-Object System.Windows.Forms.Button
	$cancel.Location = New-Object System.Drawing.Point(300, 60)
	$cancel.Size = New-Object System.Drawing.Size(75, 23)
	$cancel.Text = $Text2
	$cancel.DialogResult = 'Cancel'
	$form.CancelButton = $cancel
	$form.Controls.Add($cancel)

	$form.add_Load({
		$text.Select()
		$form.Activate()
	})

	$result = $form.ShowDialog()

	if ($XPos -and $YPos) {
		$XPos.Value = $form.Location.X
		$YPos.Value = $form.Location.Y
	}

	if ($result -eq 'OK') {
	    $text.Text
	}
}

# Starts an external file viewer.
function global:Watch-Debugger {
	param($Path)
	$Path = $Path.Replace("'", "''")
	$app = if ($PSVersionTable.PSEdition -eq 'Core' -and (Get-Command pwsh -ErrorAction 0)) {'pwsh'} else {'powershell'}
	Start-Process $app "-NoProfile -Command `$Host.UI.RawUI.WindowTitle = 'Debug output'; Get-Content -LiteralPath '$Path' -Encoding UTF8 -Wait"
}

# Writes the current invocation info.
function global:Write-DebuggerInfo {
	param($InvocationInfo, $Context)

	# write position message
	if ($_ = $InvocationInfo.PositionMessage) {
		Write-Debugger ($_.Trim())
	}

	# done?
	$file = $InvocationInfo.ScriptName
	if ($Context -le 0 -or !$file -or !(Test-Path -LiteralPath $file)) {
		return
	}

	# write file lines
	$markIndex = $InvocationInfo.ScriptLineNumber - 1
	Write-DebuggerFile $file ($markIndex - $Context) (2 * $Context + 1) $markIndex
}

# Writes the specified file lines.
function global:Write-DebuggerFile {
	param($Path, $LineIndex, $LineCount, $MarkIndex)

	# amend negative start
	if ($LineIndex -lt 0) {
		$LineCount += $LineIndex
		$LineIndex = 0
	}

	# content lines
	$lines = @(Get-Content -LiteralPath $Path -TotalCount ($LineIndex + $LineCount) -Force -ErrorAction 0)

	# leading spaces
	$space = ($lines[$LineIndex .. -1] | .{process{
		if ($_ -match '^(\s*)\S') {
			($matches[1] -replace "`t", '    ').Length
		}
	}} | Measure-Object -Minimum).Minimum

	# write lines with a mark
	Write-Debugger ''
	do {
		if (($line = $lines[$LineIndex]) -match '^(\s*)(\S.*)') {
			$line = ($matches[1] -replace "`t", '    ').Substring($space) + $matches[2]
		}
		$mark = if ($LineIndex -eq $MarkIndex) {'>>'} else {'  '}
		Write-Debugger ('{0,4}:{1} {2}' -f ($LineIndex + 1), $mark, $line)
	}
	while(++$LineIndex -lt $lines.Length)
	Write-Debugger ''
}

### Add DebuggerStop handler.
[System.Management.Automation.Runspaces.Runspace]::DefaultRunspace.Debugger.add_DebuggerStop({
	# write breakpoints
	if ($_.Breakpoints) {&{
		Write-Debugger ''
		foreach($b in $_.Breakpoints) {
			if ($b -is [System.Management.Automation.VariableBreakpoint] -and $b.Variable -eq 'StackTrace') {
				Write-Debugger 'TERMINATING ERROR BREAKPOINT'
			}
			else {
				Write-Debugger "Hit $b"
			}
		}
	}}

	# write debug location
	Write-DebuggerInfo $_.InvocationInfo $_Debugger.Context
	Write-Debugger ''

	# restore parent $_
	$_Debugger.Args = $_
	if ($_ = Get-Variable [_] -Scope 1 -ErrorAction 0) {
		$_ = $_.Value
	}

	# REPL
	for() {
		### prompt
		$_Debugger.LastAction = $_Debugger.Action
		$_Debugger.Action = Read-Debugger 'Step (h or ? for help)' $_Debugger.Action
		if ($_Debugger.Action) {
			$_Debugger.Action = $_Debugger.Action.Trim()
		}
		Write-Debugger "DBG> $($_Debugger.Action)"

		### repeat
		if ($_Debugger.Action -eq '' -and ('s', 'StepInto', 'v', 'StepOver') -contains $_Debugger.LastAction) {
			$_Debugger.Action = $_Debugger.LastAction
			$_Debugger.Args.ResumeAction = if (('s', 'StepInto') -contains $_Debugger.Action) {'StepInto'} else {'StepOver'}
			return
		}

		### Continue
		if (($null, 'c', 'Continue') -contains $_Debugger.Action) {
			$_Debugger.Args.ResumeAction = 'Continue'
			return
		}

		### StepInto
		if (('s', 'StepInto') -contains $_Debugger.Action) {
			$_Debugger.Args.ResumeAction = 'StepInto'
			return
		}

		### StepOver
		if (('v', 'StepOver') -contains $_Debugger.Action) {
			$_Debugger.Args.ResumeAction = 'StepOver'
			return
		}

		### StepOut
		if (('o', 'StepOut') -contains $_Debugger.Action) {
			$_Debugger.Args.ResumeAction = 'StepOut'
			return
		}

		### Quit
		if (('q', 'Quit') -contains $_Debugger.Action) {
			$_Debugger.Args.ResumeAction = 'Stop'
			return
		}

		### Detach
		if (('d', 'Detach') -contains $_Debugger.Action) {
			if ($_Debugger.Handlers) {
				Write-Debugger 'd, Detach - not supported in this environment.'
				continue
			}

			$_Debugger.Args.ResumeAction = 'Continue'
			Restore-Debugger
			return
		}

		### history
		if ('r' -eq $_Debugger.Action) {
			Write-Debugger $_Debugger.History
			continue
		}

		### stack
		if ('k' -ceq $_Debugger.Action) {
			Write-Debugger (Get-PSCallStack | Format-Table Command, Location, Arguments -AutoSize)
			continue
		}
		if ('K' -ceq $_Debugger.Action) {
			Write-Debugger (Get-PSCallStack | Format-List)
			continue
		}

		### <number>
		if ([int]::TryParse($_Debugger.Action, $_Debugger.RefContext)) {
			Write-DebuggerInfo $_Debugger.Args.InvocationInfo $_Debugger.RefContext.Value
			if ($_Debugger.Action[0] -eq "+") {
				$_Debugger.Context = $_Debugger.RefContext.Value
			}
			$_Debugger.Action = $_Debugger.LastAction
			continue
		}

		### watch
		if ('w' -eq $_Debugger.Action) {
			if ($_Debugger.Path) {
				Watch-Debugger $_Debugger.Path
			}
			else {
				Write-Debugger 'Debugger output file is not used.'
			}
			continue
		}

		### help
		if (('?', 'h') -contains $_Debugger.Action) {
			Write-Debugger (@(
				''
				'  s, StepInto  Step to the next statement into functions, scripts, etc.'
				'  v, StepOver  Step to the next statement over functions, scripts, etc.'
				'  o, StepOut   Step out of the current function, script, etc.'
				'  c, Continue  Continue operation.'
				if (!$_Debugger.Handlers) {
				'  d, Detach    Continue operation and detach the debugger.'
				}
				'  q, Quit      Stop operation and exit the debugger.'
				'  ?, h         Write this help message.'
				'  k            Write call stack (Get-PSCallStack).'
				'  K            Write detailed call stack using Format-List.'
				''
				'  <n>          Write debug location in context of <n> lines.'
				'  +<n>         Set location context preference to <n> lines.'
				'  k <s> <n>    Write source at stack <s> in context of <n> lines.'
				''
				if ($_Debugger.Path) {
				'  w            Restart watching the debugger output file.'
				}
				'  r            Write last PowerShell commands invoked on debugging.'
				'  <empty>      Repeat the last command if it was StepInto, StepOver.'
				'  <command>    Invoke any PowerShell <command> and write its output.'
				''
			) -join [System.Environment]::NewLine)
			continue
		}

		### stack <s> <n>
		Set-Alias k debug_stack
		function debug_stack([Parameter()][int]$s, [int]$n) {
			$stack = @(Get-PSCallStack)
			if ($s -ge $stack.Count) {
				Write-Debugger 'Out of range of the call stack.'
				return
			}
			$1 = $stack[$s]
			if (!($file = $1.ScriptName)) {
				Write-Debugger 'The caller has no script file.'
				return
			}
			if ($n -le 0) {$n = 5}
			$markIndex = $1.ScriptLineNumber - 1
			Write-Debugger $file
			Write-DebuggerFile $file ($markIndex - $n) (2 * $n + 1) $markIndex
		}

		### invoke command
		try {
			$_Debugger.History.Remove($_Debugger.Action)
			$null = $_Debugger.History.Add($_Debugger.Action)
			$_Debugger.Match = [regex]::Match($_Debugger.Action, '^\s*\$(\w+)\s*=(.*)')
			if ($_Debugger.Match.Success) {
				$value = . ([scriptblock]::Create($_Debugger.Match.Groups[2]))
				Set-Variable -Name ($_Debugger.Match.Groups[1]) -Value $value -Scope 1
				$value = "$value"
				Write-Debugger $(if ($value.Length -gt 100) {$value.Substring(0, 100) + '...'} else {$value})
			}
			else {
				Write-Debugger (. ([scriptblock]::Create($_Debugger.Action)))
			}
		}
		catch {
			Write-Debugger $(if ($_.InvocationInfo.ScriptName -like '*\Add-Debugger.ps1') {$_.ToString()} else {$_})
		}
	}
})
