
<#
.Synopsis
	Measure-Command with several iterations and progress.
	Author: Roman Kuzmin

.Description
	The script is for measuring duration of fast expressions. In order to get a
	more reliable result it invokes an expression several times and returns the
	average. Unlike Measure-Command it returns a number of milliseconds, not a
	time span which seems to be too verbose for fast expressions.

	By default the script shows the progress with some current information and
	allows immediate return of the current result on pressed [Escape]. Use the
	Test switch in order to invoke the expression once before timing and show
	the result, e.g. simply to be sure that the expression works as expected.

	The script may not work with expressions which use variables with peculiar
	names like -*, e.g. ${-MyVar}. Several such variables are used internally
	and may conflict.

.Parameter Expression
		Expression being invoked repeatedly. The default is empty {}.
.Parameter Count
		Number of iterations. The default is 1000.
.Parameter NoProgress
		Tells to not show the progress messages.
.Parameter NoEscape
		Tells to not return on pressed [Escape].
.Parameter Test
		Tells to invoke once before timing.

.Inputs
	None. Use the script parameters.
.Outputs
	Average duration in milliseconds.

.Link
	https://github.com/nightroman/PowerShelf
#>

param
(
	[Parameter()][scriptblock]$Expression = {},
	[int]$Count = 1000,
	[switch]$NoProgress,
	[switch]$NoEscape,
	[switch]$Test
)

${private:-Expression} = $Expression
${private:-Count} = $Count
${private:-NoProgress} = $NoProgress
${private:-NoEscape} = $NoEscape
${private:-Test} = $Test
Remove-Variable Expression, Count, NoProgress, NoEscape, Test

# title
${private:-title} = "Measuring: {${-Expression}}" -replace '\s+', ' '
if (!${-NoEscape}) {
	${-title} = "[Escape] to return. ${-title}"
}

# test once
if (${-Test}) {
	. ${-Expression} | Out-Host
}

# iterations
[int64]${private:-ticks} = 0
${private:-watch} = [System.Diagnostics.Stopwatch]::StartNew()
for(${private:-n} = 1; ${-n} -le ${-Count}; ++${-n}) {

	# update the sum
	${private:-ticks0} = ${-ticks}
	${-ticks} += (Measure-Command ${-Expression}).Ticks

	# update progress each second
	if (!${-NoProgress} -and ${-watch}.ElapsedMilliseconds -ge 1000) {
		${-watch} = [System.Diagnostics.Stopwatch]::StartNew()
		${private:-time} = ([timespan][int64](${-ticks} / ${-n})).TotalMilliseconds
		${private:-diff} = [int]([System.Math]::Abs(${-ticks} - ${-ticks0}) / ${-ticks} * 10000) / 100
		Write-Progress ${-title} "${-n} Average: ${-time} Change: ${-diff}%" -PercentComplete (100 * ${-n} / ${-Count})
	}

	# check for escape
	if (!${-NoEscape} -and $Host.UI.RawUI.KeyAvailable) {
		${private:-key} = $Host.UI.RawUI.ReadKey('NoEcho, IncludeKeyUp')
		if (${-key}.VirtualKeyCode -eq [System.ConsoleKey]::Escape) {
			${-Count} = ${-n}
			break
		}
	}
}

# result
([timespan][int64](${-ticks} / ${-Count})).TotalMilliseconds
