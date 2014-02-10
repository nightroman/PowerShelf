
<#
.Synopsis
	Adds a simple debugger to PowerShell.
	Author: Roman Kuzmin

.Description
	This script is designed for PowerShell hosts which do not provide their own
	debuggers, e.g. Visual Studio NuGet console ("Package Manager Host"), the
	default runspace host ("Default Host"), custom hosts, etc. This script
	should be called once at any moment when debugging is needed.

	The GUI input box is used for typing of debugger and PowerShell commands.
	For output of these commands the script uses Write-Host, built-in or fake.

	If the current runspace does not implement Write-Host or use of the cmdlet
	is not suitable then a fake global function may be defined. For example:

		function global:Write-Host { $args >> $env:TEMP\debug.log }

	In such a case an external file viewer with automatic content updates and
	scrolling should be used in order to watch produced debugging output. For
	the above example in a separate PowerShell console this command will do:

		Get-Content $env:TEMP\debug.log -Wait

.Inputs
	None
.Outputs
	None

.Example
	>
	# Enable debugging on errors in a script invoked with the default host

	$ps = [PowerShell]::Create()
	$null = $ps.AddScript({
		# Debugger
		Add-Debugger.ps1

		# Fake Write-Host
		function Write-Host { $args >> C:\TEMP\debug.log }

		# Enable debugging on terminating errors
		$null = Set-PSBreakpoint -Variable StackTrace -Mode Write

		# The main code; the debugger dialog is shown on problems
		...
	})
	$ps.Invoke()

.Link
	https://github.com/nightroman/PowerShelf
#>

# Add the stop handler and data once
if (!(Test-Path Variable:\__Debug)) {
	[System.Management.Automation.Runspaces.Runspace]::DefaultRunspace.Debugger.add_DebuggerStop({ . Invoke-DebuggerStop $_ })
	Add-Type -AssemblyName Microsoft.VisualBasic

	# Debugger data. MaximumHistoryCount and DebugContext can be changed after
	# calling the script. Other properties are internal.
	$null = New-Variable -Name __Debug -Scope Global -Description 'Debugger data.' -Option Constant -Value @{
		MaximumHistoryCount = 50
		DebugContext = 0
		Context = [ref]0
		History = @()
		Action = '?'
	}
}

# Processes DebuggerStop. It avoids variables because
# - they make noise for debugging;
# - they can conflict with other variables;
# - they can be affected by commands invoked on debugging.
function global:Invoke-DebuggerStop
{
	# event arguments
	$__Debug.e = $args[0]

	# write stop reason
	if ($PSDebugContext.Breakpoints.Count) {
		Write-Host ('Hit ' + $($PSDebugContext.Breakpoints | .{process{"$_"}} | Out-String).Trim())
	}

	# write debug location
	Show-DebugContext $__Debug.DebugContext
	Write-Host ''

	# REPL
	for(;;) {
		### prompt
		$__Debug.Action = [Microsoft.VisualBasic.Interaction]::InputBox(
			"Enter PowerShell and debug commands.`nUse h or ? for help.",
			'Debugging',
			$__Debug.Action
		).Trim()

		### echo
		Write-Host "DBG> $($__Debug.Action)"

		### continue
		if (!$__Debug.Action -or $__Debug.Action -eq 'c' -or $__Debug.Action -eq 'Continue') {
			$__Debug.e.ResumeAction = 'Continue'
			return
		}

		### StepInto
		if ($__Debug.Action -eq 's' -or $__Debug.Action -eq 'StepInto') {
			$__Debug.e.ResumeAction = 'StepInto'
			return
		}

		### StepOver
		if ($__Debug.Action -eq 'v' -or $__Debug.Action -eq 'StepOver') {
			$__Debug.e.ResumeAction = 'StepOver'
			return
		}

		### StepOut
		if ($__Debug.Action -eq 'o' -or $__Debug.Action -eq 'StepOut') {
			$__Debug.e.ResumeAction = 'StepOut'
			return
		}

		### quit
		if ($__Debug.Action -eq 'q' -or $__Debug.Action -eq 'Quit') {
			throw (New-Object System.Management.Automation.PipelineStoppedException)
		}

		### history
		if ($__Debug.Action -eq 'r') {
			Write-Host ($__Debug.History | Out-String)
			continue
		}

		### stack
		if ($__Debug.Action -ceq 'k') {
			Write-Host (Get-PSCallStack | Format-Table Command, Location, Arguments -AutoSize | Out-String)
			continue
		}
		if ($__Debug.Action -ceq 'K') {
			Write-Host (Get-PSCallStack | Format-List | Out-String)
			continue
		}

		### <number>
		if ([int]::TryParse($__Debug.Action, $__Debug.context)) {
			Show-DebugContext $__Debug.context.Value
			if ($__Debug.Action[0] -eq "+") {
				$__Debug.DebugContext = $__Debug.context.Value
			}
			continue
		}

		### help
		if ($__Debug.Action -eq '?' -or $__Debug.Action -eq 'h') {
			Write-Host @'

  s, StepInto  Step to the next statement into functions, scripts, etc.
  v, StepOver  Step to the next statement over functions, scripts, etc.
  o, StepOut   Step out of the current function, script, etc.
  c, Continue  Continue operation (also on Cancel or empty).
  q, Quit      Stop operation and exit the debugger.
  ?, h         Write this help message.
  k            Write call stack (Get-PSCallStack).
  K            Write detailed call stack using Format-List.

  <n>          Write debug location in context of <n> lines.
  +<n>         Set location context preference to <n> lines.
  k <s> <n>    Write source at stack <s> in context of <n> lines.

  r            Write last PowerShell commands invoked on debugging.
  <command>    Invoke any PowerShell <command> and write its output.

'@
			continue
		}

		### stack <s> <n>
		function k([Parameter()][int]$s, [int]$n) {
			$stack = @(Get-PSCallStack)
			if ($s -ge $stack.Count) {
				Write-Host 'Out of range of the call stack.'
				return
			}
			if (!$stack[$s].ScriptName) {
				Write-Host 'The caller has no script file.'
				return
			}
			if ($n -le 0) {$n = 5}
			$markIndex = $stack[$s].ScriptLineNumber - 1
			Show-FileContext $stack[$s].ScriptName ($markIndex - $n) (2 * $n + 1) $markIndex
		}

		### invoke command
		try {
			Write-Host (.([scriptblock]::Create($__Debug.Action)) | Out-String)
			$__Debug.History = $__Debug.History | .{
				process { if ($_ -ne $__Debug.Action) { $_ } }
				end { $__Debug.Action }
			} |
			Select-Object -Last $__Debug.MaximumHistoryCount
		}
		catch {
			Write-Host $(if ($_.InvocationInfo.ScriptName -like '*Add-Debugger.ps1') {$_.ToString()} else {$_})
		}
	}
}

# Shows source lines of the debug context.
function global:Show-DebugContext(
	[Parameter()]
	[int]$Context = 5
)
{
	# position message
	$ii = $PSDebugContext.InvocationInfo
	Write-Host $ii.PositionMessage.Trim()

	# done?
	$file = $ii.ScriptName
	if ($Context -le 0 -or !$file -or !(Test-Path -LiteralPath $file)) {
		return
	}

	# show file context
	$markIndex = $ii.ScriptLineNumber - 1
	Show-FileContext $file ($markIndex - $Context) (2 * $Context + 1) $markIndex
}

# Shows the specified file context.
function global:Show-FileContext(
	[Parameter()]
	[string]$Path,
	[int]$LineIndex,
	[int]$LineCount,
	[int]$MarkIndex
)
{
	if ($LineIndex -lt 0) {
		$LineCount += $lineIndex
		$LineIndex = 0
	}

	# context lines
	$lines = @(Get-Content -LiteralPath $Path -TotalCount ($LineIndex + $LineCount) -ErrorAction 0 -Force)

	# leading spaces
	$space = ($lines[$LineIndex .. -1] | .{process{
		if ($_ -match '^(\s*)\S') {
			($matches[1] -replace "`t", '    ').Length
		}
	}} | Measure-Object -Minimum).Minimum

	# show lines
	Write-Host ''
	do {
		if (($line = $lines[$LineIndex]) -match '^(\s*)(\S.*)') {
			$line = ($matches[1] -replace "`t", '    ').Substring($space) + $matches[2]
		}
		$mark = if ($LineIndex -eq $MarkIndex) {'=>'} else {'  '}
		Write-Host ('{0,4} {1} {2}' -f ($LineIndex + 1), $mark, $line)
	}
	while(++$LineIndex -lt $lines.Length)
	Write-Host ''
}
