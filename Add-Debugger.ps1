<#PSScriptInfo
.VERSION 2.1.0
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
	But it may replace and improve existing debuggers ("ConsoleHost").

	The script is called at any moment when debugging is needed. To restore
	the original debuggers, invoke Restore-Debugger defined by Add-Debugger.

	For output of debug commands the script uses Out-Host or a file with a
	separate console started for watching its tail.

	For input the input box is used for typing PowerShell and debugger
	commands. Specify the switch ReadHost for using Read-Host instead
	or PSReadLine if this module is imported, with its addons, e.g.
	https://www.powershellgallery.com/packages/GuiCompletion

	PowerShell commands are invoked in a child of the current scope. In order
	to change current scope variables you would use `Set-Variable -Scope 1`.
	But the script recognises `$var = ...` and assigns in the proper scope.

.Parameter Path
		Specifies the output file used instead of Out-Host.
		A separate console is opened for watching its tail.

		Do not let this file to grow too large.
		Invoke `new` when watching gets slower.

.Parameter Context
		Specifies the default numbers of context source lines to show.
		One or two integers, line numbers before and after the current.

.Parameter Environment
		Specifies the user environment variable name for keeping the state.
		It is also used as the input box title. The state includes context
		line numbers and input box coordinates.

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
	[Parameter(Position=0)]
	[string]$Path
	,
	[ValidateCount(1, 2)]
	[ValidateRange(0, 9999)]
	[int[]]$Context = @(0, 0)
	,
	[string]$Environment
	,
	[switch]$ReadHost
)

# All done?
if (Test-Path Variable:\_Debugger) {
	return
}

# Removes and gets debugger handlers.
function global:Remove-Debugger {
	$instance = [runspace]::DefaultRunspace.Debugger
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
			[runspace]::DefaultRunspace.Debugger.add_DebuggerStop($handler)
		}
	}
	Remove-Variable _Debugger -Scope Global -Force
}

function global:Read-DebuggerState {
	param($Environment, $Context)
	$n, $m = $Context
	if ($null -eq $m) {
		$m = $n
	}
	$x = -1
	$y = -1
	if ($Environment) {
		if ($string = [Environment]::GetEnvironmentVariable($Environment, 'User')) {
			try {
				$b = New-Object System.Data.Common.DbConnectionStringBuilder
				$b.set_ConnectionString($string)
				$n = [int]$b['n']
				$m = [int]$b['m']
				$x = [int]$b['x']
				$y = [int]$b['y']
			}
			catch {}
		}
	}
	[pscustomobject]@{n=$n; m=$m; x=$x; y=$y}
}

function global:Save-DebuggerState {
	if ($_Debugger.Environment) {
		$_ = $_Debugger.State
		$string = "n=$($_.n);m=$($_.m);x=$($_.x);y=$($_.y)"
		[Environment]::SetEnvironmentVariable($_Debugger.Environment, $string, 'User')
	}
}

### Set debugger data.
$null = New-Variable -Name _Debugger -Scope Global -Description Add-Debugger.ps1 -Option ReadOnly -Value @{
	Path = $null
	Environment = $Environment
	State = Read-DebuggerState $Environment $Context
	Args = $null
	Watch = $null
	History = [System.Collections.ArrayList]@()
	Handlers = Remove-Debugger
	Action = '?'
	REIndent1 = [regex]'^(\s*)'
	REIndent2 = [regex]'^(\s+)(.*)'
	RECommand = [regex]'^\s*\$(\w+)\s*=(.*)'
	REContext = [regex]'^\s*(=)?\s*(\d+)\s*(\d+)?\s*$'
	UseAnsi = $PSVersionTable.PSVersion -ge ([Version]'7.2')
	PSReadLine = if ($ReadHost -and (Get-Module PSReadLine)) {Get-PSReadLineOption}
}

### Define how to write debugger output.
if ($Path) {
	$_Debugger.Path = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($Path)
	function global:Write-Debugger {
		param($Data)
		if ($_Debugger.UseAnsi) {
			$OutputRendering = $PSStyle.OutputRendering
			$PSStyle.OutputRendering = 'ANSI'
		}
		$Data | Out-File -LiteralPath $_Debugger.Path -Encoding utf8 -ErrorAction 0 -Append
		if ($_Debugger.UseAnsi) {
			$PSStyle.OutputRendering = $OutputRendering
		}
		Watch-Debugger
	}
}
else {
	function global:Write-Debugger {
		param($Data)
		$Data | Out-Host
	}
}

### Define how to read debugger input.
if ($ReadHost) {
	function global:Read-Debugger {
		param($Prompt, $Default)
		if ($_Debugger.PSReadLine) {
			$_Debugger.temp = $_Debugger.PSReadLine.HistorySaveStyle
			$_Debugger.PSReadLine.HistorySaveStyle = 'SaveNothing'
			Write-Host "${Prompt}: " -NoNewline
			PSConsoleHostReadline
			$_Debugger.PSReadLine.HistorySaveStyle = $_Debugger.temp
		}
		else {
			Read-Host $Prompt
		}
	}
}
else {
	function global:Read-Debugger {
		param($Prompt, $Default)
		$title = if ($_Debugger.Environment) {$_Debugger.Environment} else {'Add-Debugger'}
		Read-InputBox $Prompt $title $Default Step Continue $_Debugger.State
		Save-DebuggerState
	}
}

# Gets an input string from a dialog.
function global:Read-InputBox {
	param($Prompt, $Title, $Default, $Text1, $Text2, $State)

	Add-Type -AssemblyName System.Windows.Forms, System.Drawing

	$form = New-Object System.Windows.Forms.Form
	$form.Text = $Title
	$form.TopMost = $true
	$form.Size = New-Object System.Drawing.Size(400, 132)
	$form.FormBorderStyle = 'FixedDialog'
	if ($State -and $State.x -ge 0 -and $State.y -ge 0) {
		$form.StartPosition = 'Manual'
		$form.Location = New-Object System.Drawing.Point($State.x, $State.y)
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

	if ($State) {
		$State.x = [Math]::Max(0, $form.Location.X)
		$State.y = [Math]::Max(0, $form.Location.Y)
	}

	if ($result -eq 'OK') {
	    $text.Text
	}
}

# Starts an external file viewer.
function global:Watch-Debugger {
	param([switch]$New)
	if (($exe = $_Debugger.Watch) -and !$exe.HasExited) {
		if ($New) {
			try { $exe.Kill() } catch {}
		}
		else {
			return
		}
	}
	$path = $_Debugger.Path.Replace("'", "''")
	$app = if ($PSVersionTable.PSEdition -eq 'Core' -and (Get-Command pwsh -ErrorAction 0)) {'pwsh'} else {'powershell'}
	$_Debugger.Watch = Start-Process $app "-NoProfile -Command `$Host.UI.RawUI.WindowTitle = 'Debug output'; Get-Content -LiteralPath '$path' -Encoding UTF8 -Wait" -PassThru
}

# Writes the current invocation info.
function global:Write-DebuggerInfo {
	param($InvocationInfo, $State)

	# write position message
	if ($_ = $InvocationInfo.PositionMessage) {
		Write-Debugger ($_.Trim())
	}

	if (!$State.n -and !$State.m) {
		return
	}

	$file = $InvocationInfo.ScriptName
	if (!$file -or !(Test-Path -LiteralPath $file)) {
		return
	}

	# write file lines
	$markIndex = $InvocationInfo.ScriptLineNumber - 1
	Write-DebuggerFile $file ($markIndex - $State.n) ($State.n + 1 + $State.m) $markIndex
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
	$re = $_Debugger.REIndent1
	$indent = ($lines[$LineIndex .. -1] | .{process{
		$re.Match($_).Groups[1].Value.Replace("`t", '    ').Length
	}} | Measure-Object -Minimum).Minimum

	if ($ansi = $_Debugger.UseAnsi) {
		$sMark = $PSStyle.Bold+$PSStyle.Background.Yellow
		$sLine = $PSStyle.Bold
		$sReset = $PSStyle.Reset
	}

	# write lines with a mark
	Write-Debugger ''
	$re = $_Debugger.REIndent2
	do {
		$line = $lines[$LineIndex]
		if (($m = $re.Match($line)).Success) {
			$line = $m.Groups[1].Value.Replace("`t", '    ').Substring($indent) + $m.Groups[2].Value
		}
		$isMark = $LineIndex -eq $MarkIndex
		if ($isMark -and $ansi) {
			$line = "$sMark{0,4}:$sReset>> $sLine{1}$sReset" -f ($LineIndex + 1), $line
		}
		else {
			$mark = if ($isMark) {'>>'} else {'  '}
			$line = '{0,4}:{1} {2}' -f ($LineIndex + 1), $mark, $line
		}
		Write-Debugger $line
	}
	while(++$LineIndex -lt $lines.Length)
	Write-Debugger ''
}

### Add DebuggerStop handler.
[runspace]::DefaultRunspace.Debugger.add_DebuggerStop({
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
	Write-DebuggerInfo $_.InvocationInfo $_Debugger.State
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
		if ($_Debugger.REContext.IsMatch($_Debugger.Action)) {
			&{
				$m = $_Debugger.REContext.Match($_Debugger.Action)
				$n1 = [int]$m.Groups[2].Value
				$n2 = [int]$(if ($m.Groups[3].Success) {$m.Groups[3].Value} else {$n1})
				Write-DebuggerInfo $_Debugger.Args.InvocationInfo @{n=$n1; m=$n2}
				if ($m.Groups[1].Success) {
					$_Debugger.State.n = $n1
					$_Debugger.State.m = $n2
					Save-DebuggerState
				}
			}
			continue
		}

		### new
		if ('new' -eq $_Debugger.Action -and $_Debugger.Path) {
			Remove-Item -LiteralPath $_Debugger.Path
			Write-Debugger (Get-Date)
			Watch-Debugger -New
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
				'  n1 [n2]      Write debug location in context of n lines.'
				'  = n1 [n2]    Set location context preference to n lines.'
				'  k s n1 [n2]  Write source at stack s in context of n lines.'
				''
				'  r            Write last commands invoked on debugging.'
				if ($_Debugger.Path) {
				'  new          Remove output file and start watching new.'
				}
				'  <empty>      Repeat the last command if it was StepInto, StepOver.'
				'  <command>    Invoke any PowerShell <command> and write its output.'
				''
			) -join [System.Environment]::NewLine)
			continue
		}

		### stack s n1 [n2]
		Set-Alias k debug_stack
		function debug_stack([Parameter()][int]$s, $n1, $n2) {
			$stack = @(Get-PSCallStack)
			if ($s -ge $stack.Count) {
				Write-Debugger 'Out of range of the call stack.'
				return
			}
			$stack = $stack[$s]
			if (!($file = $stack.ScriptName)) {
				Write-Debugger 'The caller has no script file.'
				return
			}
			if ($null -eq $n1) {
				$n1 = 5
				$n2 = 5
			}
			else {
				$n1 = [Math]::Max(0, [int]$n1)
				$n2 = [Math]::Max(0, $(if ($null -eq $n2) {$n1} else {[int]$n2}))
			}
			$markIndex = $stack.ScriptLineNumber - 1
			Write-Debugger $file
			Write-DebuggerFile $file ($markIndex - $n1) ($n1 + 1 + $n2) $markIndex
		}

		### invoke command
		try {
			$_Debugger.History.Remove($_Debugger.Action)
			$null = $_Debugger.History.Add($_Debugger.Action)
			$_Debugger.temp = $_Debugger.RECommand.Match($_Debugger.Action)
			if ($_Debugger.temp.Success) {
				$value = . ([scriptblock]::Create($_Debugger.temp.Groups[2]))
				Set-Variable -Name ($_Debugger.temp.Groups[1]) -Value $value -Scope 1
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
