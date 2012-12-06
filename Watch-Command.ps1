
<#
.Synopsis
	Invokes a command repeatedly and shows its one screen output.
	Author: Roman Kuzmin

.Description
	The script invokes a specified command repeatedly with specified pauses and
	shows each time one screen of output. Long lines are truncated and lines
	exceeding window height are discarded.

	- The script is for the console PowerShell.exe
	- Commands should not operate on console.
	- * indicates truncated output lines.
	- Tabs are replaced with spaces.
	- Empty lines are removed.
	- Use Ctrl-C to stop.

.Parameter Expression
		Script block which output is being watched. Default is {Get-Process}.
.Parameter Seconds
		Refresh rate in seconds. Default is 3.

.Inputs
	None. Use the parameters.
.Outputs
	None.

.Link
	https://github.com/nightroman/PowerShelf
#>

param
(
	[scriptblock]$Expression = {Get-Process},
	[int]$Seconds = 3
)

$private:_Expression = $Expression
$private:_Seconds = $Seconds
Remove-Variable Expression, Seconds

$private:sb = New-Object System.Text.StringBuilder
$private:w0 = $private:h0 = 0
for(;; Start-Sleep $_Seconds) {
	# invoke, format output
	$private:n = $sb.Length = 0
	$private:w = $Host.UI.RawUI.BufferSize.Width
	$private:h = $Host.UI.RawUI.WindowSize.Height - 1
	.{
		foreach($_ in (& $_Expression | Out-String -Stream)) {
			if ($_ -and ++$n -le $h) {
				$_ = $_.Replace("`t", ' ')
				$null = $sb.Append($(if ($_.Length -gt $w) {$_.Substring(0, $w - 1) + '*'} else {$_.PadRight($w)}))
			}
		}
	}>$null

	# write output
	if ($w0 -ne $w -or $h0 -ne $h) {
		$w0 = $w; $h0 = $h
		Clear-Host
		$private:origin = $Host.UI.RawUI.CursorPosition
	}
	else {
		$Host.UI.RawUI.CursorPosition = $origin
	}
	Write-Host $sb -NoNewLine
	$private:cursor = $Host.UI.RawUI.CursorPosition
	if ($n -lt $h) {
		Write-Host (' ' * ($w * ($h - $n) + 1)) -NoNewLine
	}
	elseif ($n -gt $h) {
		Write-Host * -NoNewLine
	}
	$Host.UI.RawUI.CursorPosition = $cursor
}
