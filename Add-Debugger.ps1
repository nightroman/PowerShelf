<#PSScriptInfo
.VERSION 3.0.1
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
	The script adds or replaces existing debugger in any runspace. It is
	useful for hosts with no own debuggers, e.g. 'Default Host', 'Package
	Manager Host', 'FarHost'. Or it may replace existing debuggers, e.g.
	in "ConsoleHost".

	The script is called at any moment when debugging is needed. To restore
	the original debuggers, invoke Restore-Debugger defined by Add-Debugger.

	Console like hosts include 'ConsoleHost', 'Visual Studio Code Host',
	'Package Manager Host'. They imply using Read-Host and Write-Host by
	default. Other hosts use GUI input box and output file watching.

	Env data are saved as "HKCU\Software\VB and VBA Program Settings\Add-Debugger\<env>".
	Env "$shared" keeps common data, users may change:

	- "watch_app", "watch_args"

		Watcher application and its arguments.
		(1) "watch_app" may be "pwsh" or "powershell" with empty "watch_args".
		(2) "watch_app" may be "wt" with "watch_args" ending with "pwsh" or "powershell":

			watch_app  : wt.exe
			watch_args : --window -1 --pos 0,0 --size 80,50 --title Debug pwsh.exe

	- "history"

		History of typed PowerShell statements (automatically updated 50 last items).

.Parameter Path
		Specifies the file used for debugger output. A separate console is
		used for watching its tail. Do not let the file to grow too large.
		Invoke `new` when watching gets slower.

		"$env:TEMP\$Env.log" is used by default.
		The default file is deleted before debugging.

.Parameter Context
		One or two integers, shown line counts before and after the current.

		Default: @(4, 4)

.Parameter Env
		Specifies the environment name for saving the state. It is also used as
		the input box title and the default output file name.

		The saved state includes context line numbers and input box coordinates.

		Default: "Add-Debugger"

.Parameter ReadGui
		Tells to use GUI input boxes for input.

.Parameter ReadHost
		Tells to use Read-Host or PSReadLine for input.
		PSReadLine should be imported and configured beforehand.

.Parameter WriteHost
		Tells to use Write-Host and Out-Host for debugger output.

.Example
	>
	# How to debug bare runspaces
	$script = {
		Add-Debugger  # add debugger with default options
		Wait-Debugger # use hardcoded or other breakpoints
	}
	$ps = [PowerShell]::Create().AddScript('& $args[0]').AddArgument($script)
	$null = $ps.BeginInvoke()

.Link
	https://github.com/nightroman/PowerShelf/blob/main/docs/Add-Debugger.ps1.md
#>

[CmdletBinding(DefaultParameterSetName='Main')]
param(
	[Parameter(Position=0)]
	[string]$Path
	,
	[ValidateCount(1, 2)]
	[ValidateRange(0, 999)]
	[int[]]$Context = @(4, 4)
	,
	[string]$Env = 'Add-Debugger'
	,
	[switch]$WriteHost
	,
	[Parameter(ParameterSetName='ReadGui', Mandatory=1)]
	[switch]$ReadGui
	,
	[Parameter(ParameterSetName='ReadHost', Mandatory=1)]
	[switch]$ReadHost
)

# All done?
if (Test-Path Variable:\_Debugger) {
	return
}

# Removes and gets debugger handlers.
function global:Remove-Debugger {
	$debugger = [runspace]::DefaultRunspace.Debugger
	$type = [System.Management.Automation.Debugger]
	$e = $type.GetEvent('DebuggerStop')
	$v = $type.GetField('DebuggerStop', ([System.Reflection.BindingFlags]'NonPublic, Instance')).GetValue($debugger)
	if ($v) {
		$handlers = $v.GetInvocationList()
		foreach($handler in $handlers) {
			$e.RemoveEventHandler($debugger, $handler)
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
	param($Env, $Context)

	if ($Env) {
		[int]$n = [Microsoft.VisualBasic.Interaction]::GetSetting('Add-Debugger', $Env, 'n', 3)
		[int]$m = [Microsoft.VisualBasic.Interaction]::GetSetting('Add-Debugger', $Env, 'm', $n)
		[int]$x = [Microsoft.VisualBasic.Interaction]::GetSetting('Add-Debugger', $Env, 'x', -1)
		[int]$y = [Microsoft.VisualBasic.Interaction]::GetSetting('Add-Debugger', $Env, 'y', -1)
	}
	else {
		$x, $y = -1
		$n, $m = $Context
		if ($null -eq $m) {
			$m = $n
		}
	}

	$data = [pscustomobject]@{n=$n; m=$m; x=$x; y=$y}
	@{
		Data = $data
		Text = "$data"
	}
}

function global:Save-DebuggerState {
	if (!($env = $_Debugger.Env)) {
		return
	}

	$state = $_Debugger.State
	$data = $state.Data
	if ($state.Text -ceq "$data") {
		return
	}

	[Microsoft.VisualBasic.Interaction]::SaveSetting('Add-Debugger', $env, 'n', $data.n)
	[Microsoft.VisualBasic.Interaction]::SaveSetting('Add-Debugger', $env, 'm', $data.m)
	[Microsoft.VisualBasic.Interaction]::SaveSetting('Add-Debugger', $env, 'x', $data.x)
	[Microsoft.VisualBasic.Interaction]::SaveSetting('Add-Debugger', $env, 'y', $data.y)
}

### Init debugger data.
Add-Type -AssemblyName Microsoft.VisualBasic

$IsConsoleLikeHost = $Host.Name -in ('ConsoleHost', 'Visual Studio Code Host', 'Package Manager Host')

if (!$ReadHost -and !$ReadGui -and $IsConsoleLikeHost) {
	$ReadHost = $true
}

if (!$WriteHost -and !$Path -and $IsConsoleLikeHost) {
	$WriteHost = $true
}

if (!$WriteHost -and !$Path) {
	$Path = "$env:TEMP\$Env.log"
	[System.IO.File]::Delete($Path)
}
elseif (!$WriteHost) {
	$Path = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($Path)
}
else {
	$Path = $null
}

if ($history = [Microsoft.VisualBasic.Interaction]::GetSetting('Add-Debugger', '$shared', 'history')) {
	$history = $history -split ' _ '
}
else {
	$history = @()
}

$null = New-Variable -Name _Debugger -Scope Global -Description Add-Debugger.ps1 -Option ReadOnly -Value @{
	Path = $Path
	Env = $Env
	State = Read-DebuggerState $Env $Context
	Module = $null
	Args = $null
	Watch = $null
	History = [System.Collections.Generic.List[string]]$history
	Handlers = Remove-Debugger
	PS = $null
	Action = ''
	REIndent1 = [regex]'^(\s*)'
	REIndent2 = [regex]'^(\s+)(.*)'
	REContext = [regex]'^\s*(=)?\s*(\d+)\s*(\d+)?\s*$'
	UseAnsi = $PSVersionTable.PSVersion -ge ([Version]'7.2')
	PSReadLine = if ($ReadHost -and (Get-Module PSReadLine)) {Get-PSReadLineOption}
}

### Define debugger output.
if ($Path) {
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

### Define debugger input.
if ($ReadHost -and $_Debugger.PSReadLine) {
	function global:Read-Debugger {
		param($Prompt, $Default)
		$_Debugger.q1 = $_Debugger.PSReadLine.HistorySaveStyle
		$_Debugger.PSReadLine.HistorySaveStyle = 'SaveNothing'
		Write-Host "${Prompt}: " -NoNewline
		try {
			PSConsoleHostReadline
		}
		finally {
			$_Debugger.PSReadLine.HistorySaveStyle = $_Debugger.q1
		}
	}
}
elseif ($ReadHost) {
	function global:Read-Debugger {
		param($Prompt, $Default)
		Read-Host $Prompt
	}
}
else {
	function global:Read-Debugger {
		param($Prompt, $Default)
		$title = if ($_Debugger.Env) {$_Debugger.Env} else {'Add-Debugger'}
		Read-InputBox $Prompt $title $Default Step Continue $_Debugger.State.Data
		Save-DebuggerState
	}
}

# Gets an input string from a dialog.
function global:Read-InputBox {
	param($Prompt, $Title, $Default, $Text1, $Text2, $State)

	$script = {
		Add-Type -AssemblyName System.Windows.Forms

		$form = [System.Windows.Forms.Form]::new()
		$form.Text = $Title
		$form.TopMost = $true
		$form.Size = [System.Drawing.Size]::new(400, 132)
		$form.FormBorderStyle = 'FixedDialog'
		if ($State -and $State.x -ge 0 -and $State.y -ge 0) {
			$form.StartPosition = 'Manual'
			$form.Location = [System.Drawing.Point]::new($State.x, $State.y)
		}
		else {
			$form.StartPosition = 'CenterScreen'
		}

		$label = [System.Windows.Forms.Label]::new()
		$label.Location = [System.Drawing.Point]::new(10, 10)
		$label.Size = [System.Drawing.Size]::new(380, 20)
		$label.Text = $Prompt
		$form.Controls.Add($label)

		$combo = [Windows.Forms.ComboBox]::new()
		$combo.Text = $Default
		$combo.Location = [System.Drawing.Point]::new(10, 30)
		$combo.Size = [System.Drawing.Size]::new(365, 20)
		$combo.DropDownStyle = 'DropDown'
		$combo.AutoCompleteMode = 'SuggestAppend'
		$combo.AutoCompleteSource = 'ListItems'
		foreach($_ in $_Debugger.History) {
			$null=$combo.Items.Add($_)
		}
		$form.Controls.Add($combo)

		$ok = [System.Windows.Forms.Button]::new()
		$ok.Location = [System.Drawing.Point]::new(225, 60)
		$ok.Size = [System.Drawing.Size]::new(75, 23)
		$ok.Text = $Text1
		$ok.DialogResult = 'OK'
		$form.AcceptButton = $ok
		$form.Controls.Add($ok)

		$continue = [System.Windows.Forms.Button]::new()
		$continue.Location = [System.Drawing.Point]::new(300, 60)
		$continue.Size = [System.Drawing.Size]::new(75, 23)
		$continue.Text = $Text2
		$continue.DialogResult = 'Ignore'
		$form.Controls.Add($continue)

		$form.add_Load({
			$combo.Select()
			$form.Activate()
		})

		$result = $form.ShowDialog()

		if ($State) {
			$State.x = [Math]::Max(0, $form.Location.X)
			$State.y = [Math]::Max(0, $form.Location.Y)
		}

		if ($result -eq 'OK') {
			return $combo.Text
		}

		if ($result -eq 'Ignore') {
			return 'continue'
		}

		'quit'
	}.GetNewClosure()

	if (!($ps = $_Debugger.PS)) {
		$rs =  [runspacefactory]::CreateRunspace()
		$rs.ApartmentState = 'STA'
		$rs.Open()
		$_Debugger.PS = $ps = [powershell]::Create()
		$ps.Runspace = $rs
	}

	$ps.Commands.Clear()
	$ps.AddScript('& $args[0]').AddArgument($script).Invoke()
}

# Starts an external file viewer.
function global:Watch-Debugger {
	if (($exe = $_Debugger.Watch) -and !$exe.HasExited) {
		return
	}

	$watch_app = [Microsoft.VisualBasic.Interaction]::GetSetting('Add-Debugger', '$shared', 'watch_app', ':')
	$watch_args = [Microsoft.VisualBasic.Interaction]::GetSetting('Add-Debugger', '$shared', 'watch_args', ':')

	if ($watch_app -and $watch_app -ne ':') {
		$_ = if ($watch_args) {$watch_args} else {$watch_app}
		if ($_ -notmatch '\b(pwsh|powershell)(\.exe)?$') {
			if ($watch_args -and $watch_args -ne ':') {
				throw "Expected: 'watch_args' ends with 'pwsh' or 'powershell'. Actual: '$watch_args'."
			}
			else {
				throw "Expected: 'watch_app' with empty 'watch_args' specifies 'pwsh' or 'powershell'. Actual: '$watch_app'."
			}
		}
		$pwsh = "$($Matches[1]).exe"
	}
	else {
		$init = $watch_app + $watch_args

		$pwsh = if (Get-Command pwsh.exe -ErrorAction Ignore) {'pwsh.exe'} else {'powershell.exe'}
		if (Get-Command wt.exe -ErrorAction Ignore) {
			$watch_app = 'wt.exe'
			$watch_args = "--window -1 --pos 0,0 --title `"Debug output`" $pwsh"
		}
		else {
			$watch_app = $pwsh
			$watch_args = ''
		}

		if ($init -eq '::') {
			[Microsoft.VisualBasic.Interaction]::SaveSetting('Add-Debugger', '$shared', 'watch_app', $watch_app)
			[Microsoft.VisualBasic.Interaction]::SaveSetting('Add-Debugger', '$shared', 'watch_args', $watch_args)
		}
	}

	$path = $_Debugger.Path.Replace("\", "/").Replace("'", "''")
	Start-Process $watch_app "$watch_args -nop -c Get-Content -LiteralPath '$path' -Encoding UTF8 -ErrorAction Ignore -Wait"

	$query = [System.Management.ManagementObjectSearcher]::new(@"
SELECT ProcessId FROM Win32_Process WHERE Name='$pwsh' AND CommandLine LIKE "%$path%"
"@)

	for($process = $null) {
		Start-Sleep -Milliseconds 100
		if ($r = @($query.Get())) {
			$process = Get-Process -Id $r[0].ProcessId
			break
		}
	}
	$_Debugger.Watch = $process
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
			$line = "$sMark{0,3}:$sReset>> $sLine{1}$sReset" -f ($LineIndex + 1), $line
		}
		else {
			$mark = if ($isMark) {'>>'} else {'  '}
			$line = '{0,3}:{1} {2}' -f ($LineIndex + 1), $mark, $line
		}
		Write-Debugger $line
	}
	while(++$LineIndex -lt $lines.Length)
	Write-Debugger ''
}

### Main.
Add-Type @'
using System;
using System.Management.Automation;
public class AddDebuggerHelpers
{
	public ScriptBlock DebuggerStopProxy;
	public EventHandler<DebuggerStopEventArgs> DebuggerStopHandler { get { return OnDebuggerStop; } }
	void OnDebuggerStop(object sender, DebuggerStopEventArgs e)
	{
		SessionState state = ((EngineIntrinsics)ScriptBlock.Create("$ExecutionContext").Invoke()[0].BaseObject).SessionState;
		state.InvokeCommand.InvokeScript(false, DebuggerStopProxy, null, state.Module, e);
	}
}
'@

### Add DebuggerStop handler.
$AddDebuggerHelpers = [AddDebuggerHelpers]::new()
[runspace]::DefaultRunspace.Debugger.add_DebuggerStop($AddDebuggerHelpers.DebuggerStopHandler)
$AddDebuggerHelpers.DebuggerStopProxy = {
	param($_module, $_args)

	# write breakpoints
	if ($_args.Breakpoints) {&{
		Write-Debugger ''
		foreach($bp in $_args.Breakpoints) {
			if ($bp -is [System.Management.Automation.VariableBreakpoint] -and $bp.Variable -eq 'StackTrace') {
				Write-Debugger 'TERMINATING ERROR BREAKPOINT'
			}
			else {
				Write-Debugger "Hit $bp"
			}
		}
	}}

	# write debug location
	Write-DebuggerInfo $_args.InvocationInfo $_Debugger.State.Data
	Write-Debugger ''

	# hide local variables
	$_Debugger.Module = $_module
	$_Debugger.Args = $_args
	Remove-Variable _module, _args -Scope 0

	# REPL
	for() {
		### prompt
		$_Debugger.LastAction = $_Debugger.Action
		$_Debugger.Action = Read-Debugger 'Step (h or ? for help)' $_Debugger.Action
		if ($_Debugger.Action) {
			$_Debugger.Action = $_Debugger.Action.Trim()
		}
		if (${env:Add-Debugger-Action} -and $_Debugger.Action -in ('s', 'StepInto', 'v', 'StepOver', 'o', 'StepOut', 'c', 'Continue', 'd', 'Detach', 'q', 'Quit')) {
			$_Debugger.Action = ${env:Add-Debugger-Action}
		}
		Write-Debugger "[DBG]: $($_Debugger.Action)"

		### repeat
		if ($_Debugger.Action -eq '' -and $_Debugger.LastAction -in ('s', 'StepInto', 'v', 'StepOver')) {
			$_Debugger.Action = $_Debugger.LastAction
			$_Debugger.Args.ResumeAction = if ($_Debugger.Action -in ('s', 'StepInto')) {'StepInto'} else {'StepOver'}
			return
		}

		### Continue
		if ($_Debugger.Action -in ($null, 'c', 'Continue')) {
			$_Debugger.Args.ResumeAction = 'Continue'
			return
		}

		### StepInto
		if ($_Debugger.Action -in ('s', 'StepInto')) {
			$_Debugger.Args.ResumeAction = 'StepInto'
			return
		}

		### StepOver
		if ($_Debugger.Action -in ('v', 'StepOver')) {
			$_Debugger.Args.ResumeAction = 'StepOver'
			return
		}

		### StepOut
		if ($_Debugger.Action -in ('o', 'StepOut')) {
			$_Debugger.Args.ResumeAction = 'StepOut'
			return
		}

		### Quit
		if ($_Debugger.Action -in ('q', 'Quit')) {
			$_Debugger.Args.ResumeAction = 'Stop'
			return
		}

		### Detach
		if ($_Debugger.Action -in ('d', 'Detach')) {
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
					$_Debugger.State.Data.n = $n1
					$_Debugger.State.Data.m = $n2
					Save-DebuggerState
				}
			}
			continue
		}

		### new
		if ('new' -eq $_Debugger.Action -and $_Debugger.Path) {
			[System.IO.File]::WriteAllBytes($_Debugger.Path, @())
			Watch-Debugger
			continue
		}

		### help
		if ($_Debugger.Action -in ('?', 'h')) {
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
			$_Debugger.q1 = [scriptblock]::Create($_Debugger.Action)
			$_Debugger.q2 = $global:Error.Count
			if ($_Debugger.Module) {
				$_Debugger.q1 = $_Debugger.Module.NewBoundScriptBlock($_Debugger.q1)
			}
			Write-Debugger (. $_Debugger.q1)
			if ($_Debugger.q2 -ne $global:Error.Count) {
				$_ = $global:Error[0]
				Write-Debugger $(if ($_.InvocationInfo.ScriptName) {$_} else {"ERROR: $_"})
			}

			### history
			$null=$_Debugger.History.Remove($_Debugger.Action)
			$_Debugger.History.Insert(0, $_Debugger.Action)
			while($_Debugger.History.Count -gt 50) {
				$_Debugger.History.RemoveAt($_Debugger.History.Count - 1)
			}
			[Microsoft.VisualBasic.Interaction]::SaveSetting('Add-Debugger', '$shared', 'history', [string]::Join(' _ ', $_Debugger.History))
		}
		catch {
			Write-Debugger $(if ($_.InvocationInfo.ScriptName) {$_} else {"ERROR: $_"})
		}
		Write-Debugger ''
	}
}
