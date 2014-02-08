
<#
.Synopsis
	Adds a simple debugger to PowerShell.
	Author: Roman Kuzmin

.Description
	This script is designed for PowerShell hosts which do not provide their own
	debuggers, e.g. Visual Studio NuGet console ("Package Manager Host"), the
	default runspace host ("Default Host"), etc. The script should be called
	once at any moment when debugging is needed.

	The GUI input box is used for typing of PowerShell and debugger commands.
	For output of command results, debug context script lines, and other data
	the script uses Write-Host, built-in or fake.

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
		LastAction = '?'
		History = @()
		Context = [ref]0
		Action = $null
		e = $null
	}
}

# Processes the debugger stop event. It does not use variables because
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
			"Enter PowerShell or debug command`n? or h for help",
			'Debugging',
			$__Debug.LastAction
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
			$__Debug.LastAction = $__Debug.Action
			$__Debug.e.ResumeAction = 'StepInto'
			return
		}

		### StepOver
		if ($__Debug.Action -eq 'v' -or $__Debug.Action -eq 'StepOver') {
			$__Debug.LastAction = $__Debug.Action
			$__Debug.e.ResumeAction = 'StepOver'
			return
		}

		### StepOut
		if ($__Debug.Action -eq 'o' -or $__Debug.Action -eq 'StepOut') {
			$__Debug.e.ResumeAction = 'StepOut'
			return
		}

		### history
		if ($__Debug.Action -eq 'r') {
			Write-Host ($__Debug.History | Out-String)
			continue
		}

		### stack
		if ($__Debug.Action -eq 'k') {
			Write-Host (Get-PSCallStack | Format-Table -AutoSize | Out-String)
			continue
		}

		### quit
		if ($__Debug.Action -eq 'q' -or $__Debug.Action -eq 'Quit') {
			throw (New-Object System.Management.Automation.PipelineStoppedException)
		}

		### <number>
		if ([int]::TryParse($__Debug.Action, $__Debug.context)) {
			if ($__Debug.Action[0] -eq "+") {
				$__Debug.DebugContext = $__Debug.context.Value
			}
			else {
				Show-DebugContext $__Debug.context.Value
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
  ?, h         Display this help message.
  r            Display PowerShell command history.
  k            Display call stack (Get-PSCallStack).
  <number>     Show debug location in context of <number> lines.
  +<number>    Set location context preference to <number> lines.
  <command>    Invoke any PowerShell <command> and write its output.

'@
			continue
		}

		# parse command
		try {
			$__Debug.Action = [scriptblock]::Create($__Debug.Action)
		}
		catch {
			Write-Host $_
			continue
		}

		# invoke command
		try {
			Write-Host (. $__Debug.Action | Out-String)
			$__Debug.History = $__Debug.History | .{
				process { if ($_ -ne $__Debug.Action) { $_ } }
				end { $__Debug.Action }
			} |
			Select-Object -Last $__Debug.MaximumHistoryCount
		}
		catch {
			Write-Host ($_ | Out-String)
		}
	}
}

# Shows source lines of the debug context.
function global:Show-DebugContext(
	[Parameter()]
	[int]$Context = 5
)
{
	# invocation info
	if (!($ii = $PSCmdlet.GetVariableValue('PSDebugContext'))) {return}
	$ii = $PSDebugContext.InvocationInfo

	# position message
	Write-Host $ii.PositionMessage.Trim()

	# done?
	$file = $ii.ScriptName
	if ($Context -le 0 -or !$file -or !(Test-Path -LiteralPath $file)) {
		return
	}

	# context lines
	$lines = @(Get-Content -LiteralPath $file -TotalCount ($ii.ScriptLineNumber + $Context) -ErrorAction 0 -Force)
	$lineIndex = $ii.ScriptLineNumber - 1
	$index = [Math]::Max($lineIndex - $Context, 0)

	# leading spaces
	$space = ($lines[$index .. -1] | .{process{
		if ($_ -match '^(\s*)\S') {
			($matches[1] -replace "`t", '    ').Length
		}
	}} | Measure-Object -Minimum).Minimum

	# show lines
	Write-Host ''
	do {
		if (($line = $lines[$index]) -match '^(\s*)(\S.*)') {
			$line = ($matches[1] -replace "`t", '    ').Substring($space) + $matches[2]
		}
		$mark = if ($index -eq $lineIndex) {'=>'} else {'  '}
		Write-Host ('{0,4} {1} {2}' -f ($index + 1), $mark, $line)
	}
	while(++$index -lt $lines.Length)
	Write-Host ''
}
