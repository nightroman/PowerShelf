<#PSScriptInfo
.DESCRIPTION Debugger for hosts with no own debugger.
.VERSION 1.0.0
.AUTHOR Roman Kuzmin
.COPYRIGHT (c) Roman Kuzmin
.TAGS Debug
.GUID e187060e-ad39-425c-a6e3-b1e1e92ab59d
.LICENSEURI http://www.apache.org/licenses/LICENSE-2.0
.PROJECTURI https://github.com/nightroman/PowerShelf
#>
<#
.Synopsis
	Adds a script debugger to PowerShell.
	Author: Roman Kuzmin

.Description
	This script is designed for PowerShell runspaces which do not have their
	own debuggers, e.g. Visual Studio NuGet console ("Package Manager Host"),
	the default runspace host ("Default Host"), and etc. But it can be used
	instead of build-in debuggers as well.

	The script should be called once at any moment when debugging is needed.
	In order to restore the original debugger invoke Restore-Debugger. This
	function is defined by Add-Debugger.

	For output of debug commands the script uses Out-Host or a file with a
	separate console started for watching its tail.

	For input the GUI input box is used for typing PowerShell and debugger
	commands. Use the switch ReadHost in order to use Read-Host instead.

.Parameter Path
		Specifies the output file used instead of Out-Host.
		A separate console is opened for watching its tail.

.Parameter ReadHost
		Tells to use Read-Host for input instead of the GUI input box.

.Inputs
	None
.Outputs
	None

.Example
	>
	How to debug terminating errors in a bare runspace. Use cases:
	- In .NET the similar code is typical for invoking PowerShell.
	- In PowerShell BeginInvoke() makes sense for background jobs.

	$ps = [PowerShell]::Create()
	$null = $ps.AddScript({
		# add debugger with file output
		Add-Debugger.ps1 $env:TEMP\debug.log

		# enable debugging on terminating errors
		$null = Set-PSBreakpoint -Variable StackTrace -Mode Write

		# from now on the debugger dialog is shown on failures
		# and a separate PowerShell output console is started
		...
	})
	$ps.Invoke() # or BeginInvoke()

.Link
	https://github.com/nightroman/PowerShelf
#>

param(
	[Parameter()]
	[string]$Path,
	[switch]$ReadHost,
	[int]$XPos = -1,
	[int]$YPos = -1
)

# Restore another debugger by its Restore-Debugger.
if ((Test-Path Variable:\_Debugger) -and (Get-Variable _Debugger).Description -ne 'Add-Debugger.ps1') {
	Restore-Debugger
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
	if (!(Test-Path Variable:\_Debugger)) {return}
	$null = Remove-Debugger
	if ($_Debugger.Handlers) {
		foreach($handler in $_Debugger.Handlers) {
			[System.Management.Automation.Runspaces.Runspace]::DefaultRunspace.Debugger.add_DebuggerStop($handler)
		}
	}
	Remove-Variable _Debugger -Scope Global -Force
}

# Add the debugger and data once
if (!(Test-Path Variable:\_Debugger)) {
	$null = New-Variable -Name _Debugger -Scope Global -Description Add-Debugger.ps1 -Option ReadOnly -Value @{
		History = [System.Collections.ArrayList]@()
		Handlers = Remove-Debugger
		DefaultContext = 0
		Context = [ref]0
		Action = '?'
		XPos = $XPos
		YPos = $YPos
	}
	[System.Management.Automation.Runspaces.Runspace]::DefaultRunspace.Debugger.add_DebuggerStop({. Invoke-DebuggerStop})
}

# Writes debugger output.
if ($Path) {
	$_Debugger.Path = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($Path)
	$_Debugger.Watch = $true
	function global:Write-Debugger($Data)
	{
		[System.IO.File]::AppendAllText($_Debugger.Path, ($Data | Out-String), [System.Text.Encoding]::Unicode)
		if ($_Debugger.Watch) {
			$_Debugger.Watch = $false
			Watch-Debugger $_Debugger.Path
		}
	}
}
else {
	$_Debugger.Path = $null
	function global:Write-Debugger($Data)
	{
		$Data | Out-Host
	}
}

# Reads debugger input.
if ($ReadHost) {
	function global:Read-Debugger(
		$Prompt,
		$Title,
		$Default
	)
	{
		Read-Host $Prompt
	}
}
else {
	Add-Type -AssemblyName Microsoft.VisualBasic
	function global:Read-Debugger(
		$Prompt,
		$Title,
		$Default
	)
	{
		[Microsoft.VisualBasic.Interaction]::InputBox($Prompt, $Title, $Default, $_Debugger.XPos, $_Debugger.YPos)
	}
}

# Starts an external file viewer.
function global:Watch-Debugger($Path)
{
	$Path = $Path.Replace("'", "''")
	$me = Get-Process -Id $PID
	$app = if ($me.Name -eq 'pwsh') {$me.Path} else {'powershell.exe'}
	Start-Process $app "-NoProfile -Command Get-Content -LiteralPath '$Path' -Wait -ErrorAction 0"
}

# Writes the current invocation info.
function global:Write-DebuggerInfo(
	$InvocationInfo,
	$Context
)
{
	# write position message
	if ($_ = $InvocationInfo.PositionMessage) {
		Write-Debugger ($_.Trim())
	}

	# done?
	$file = $InvocationInfo.ScriptName
	if ($Context -le 0 -or !$file -or !(Test-Path -LiteralPath $file)) {return}

	# write file lines
	$markIndex = $InvocationInfo.ScriptLineNumber - 1
	Write-DebuggerFile $file ($markIndex - $Context) (2 * $Context + 1) $markIndex
}

# Writes the specified file lines.
function global:Write-DebuggerFile(
	$Path,
	$LineIndex,
	$LineCount,
	$MarkIndex
)
{
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
		$mark = if ($LineIndex -eq $MarkIndex) {'=>'} else {'  '}
		Write-Debugger ('{0,4} {1} {2}' -f ($LineIndex + 1), $mark, $line)
	}
	while(++$LineIndex -lt $lines.Length)
	Write-Debugger ''
}

# Processes DebuggerStop events.
function global:Invoke-DebuggerStop
{
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
	Write-DebuggerInfo $_.InvocationInfo $_Debugger.DefaultContext
	Write-Debugger ''

	# REPL
	$_Debugger.e = $_
	for() {
		### prompt
		$_Debugger.Action = Read-Debugger "Enter PowerShell and debug commands.`nUse h or ? for help" Debugger $_Debugger.Action
		$_Debugger.Action = if ($null -eq $_Debugger.Action) {''} else {$_Debugger.Action.Trim()}
		Write-Debugger "DBG> $($_Debugger.Action)"

		### Continue
		if (!$_Debugger.Action -or $_Debugger.Action -eq 'c' -or $_Debugger.Action -eq 'Continue') {
			$_Debugger.e.ResumeAction = 'Continue'
			return
		}

		### StepInto
		if ($_Debugger.Action -eq 's' -or $_Debugger.Action -eq 'StepInto') {
			$_Debugger.e.ResumeAction = 'StepInto'
			return
		}

		### StepOver
		if ($_Debugger.Action -eq 'v' -or $_Debugger.Action -eq 'StepOver') {
			$_Debugger.e.ResumeAction = 'StepOver'
			return
		}

		### StepOut
		if ($_Debugger.Action -eq 'o' -or $_Debugger.Action -eq 'StepOut') {
			$_Debugger.e.ResumeAction = 'StepOut'
			return
		}

		### Quit
		if ($_Debugger.Action -eq 'q' -or $_Debugger.Action -eq 'Quit') {
			$_Debugger.e.ResumeAction = 'Stop'
			return
		}

		### Detach
		if ($_Debugger.Action -eq 'd' -or $_Debugger.Action -eq 'Detach') {
			if ($_Debugger.Handlers) {
				Write-Debugger 'd, Detach - not supported in this environment.'
				continue
			}

			$_Debugger.e.ResumeAction = 'Continue'
			Restore-Debugger
			return
		}

		### history
		if ($_Debugger.Action -eq 'r') {
			Write-Debugger $_Debugger.History
			continue
		}

		### stack
		if ($_Debugger.Action -ceq 'k') {
			Write-Debugger (Get-PSCallStack | Format-Table Command, Location, Arguments -AutoSize)
			continue
		}
		if ($_Debugger.Action -ceq 'K') {
			Write-Debugger (Get-PSCallStack | Format-List)
			continue
		}

		### <number>
		if ([int]::TryParse($_Debugger.Action, $_Debugger.Context)) {
			Write-DebuggerInfo $_Debugger.e.InvocationInfo $_Debugger.Context.Value
			if ($_Debugger.Action[0] -eq "+") {
				$_Debugger.DefaultContext = $_Debugger.Context.Value
			}
			continue
		}

		### watch
		if ($_Debugger.Action -eq 'w') {
			if ($_Debugger.Path) {
				Watch-Debugger $_Debugger.Path
			}
			else {
				Write-Debugger 'Debugger output file is not used.'
			}
			continue
		}

		### help
		if ($_Debugger.Action -eq '?' -or $_Debugger.Action -eq 'h') {
			Write-Debugger (@(
				''
				'  s, StepInto  Step to the next statement into functions, scripts, etc.'
				'  v, StepOver  Step to the next statement over functions, scripts, etc.'
				'  o, StepOut   Step out of the current function, script, etc.'
				'  c, Continue  Continue operation (also on empty input).'

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
				'  w            Restart watching the debugger output file.'
				'  r            Write last PowerShell commands invoked on debugging.'
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
			Write-Debugger (.([scriptblock]::Create($_Debugger.Action)))
		}
		catch {
			Write-Debugger $(if ($_.InvocationInfo.ScriptName -like '*\Add-Debugger.ps1') {$_.ToString()} else {$_})
		}
	}
}
