<#
.Synopsis
	Measure-Command with several iterations and progress.
	Author: Roman Kuzmin

.Description
	The script is for measuring duration of fast expressions. In order to get a
	more reliable result it invokes an expression several times and returns the
	average. Unlike Measure-Command, it returns milliseconds, not a time span.

	By default the script shows the progress with some current information and
	allows immediate return of the current result on pressed [Escape].

	Use the switch Test in order to invoke the expression once before timing
	and show the result, e.g. simply to be sure that the expression works as
	expected.

	The script may not work with expressions using variables with peculiar
	names like -*, e.g. ${-MyVar}. Such variables are used internally.

.Parameter Expression
		Specifies one or more expressions being invoked repeatedly.

.Parameter Count
		Number of iterations. The default is 1000.

.Parameter NoProgress
		Tells to not show the progress messages.

.Parameter NoEscape
		Tells to not return on pressed [Escape].

.Parameter Test
		Tells to invoke once before timing.
		The result is written to the output.

.Inputs
	None. Use the script parameters.

.Outputs
	Average duration in milliseconds.
	It comes after Test output, if any.

.Link
	https://github.com/nightroman/PowerShelf
#>

[CmdletBinding()]
param(
	[Parameter(Mandatory=1)]
	[scriptblock[]]$Expression
	,
	[int]$Count = 1000
	,
	[switch]$NoProgress
	,
	[switch]$NoEscape
	,
	[switch]$Test
)

trap {
	Write-Warning 'For more details try to examine $Error.'
	$PSCmdlet.ThrowTerminatingError($_)
}

function Measure-Script {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory=1)]
		[scriptblock]$Expression
		,
		[int]$Count = 1000
		,
		[switch]$NoProgress
		,
		[switch]$NoEscape
		,
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
		. ${-Expression}
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
}

### main

${private:-Expression} = $Expression
Remove-Variable Expression, Count, NoProgress, NoEscape, Test

foreach($_ in ${-Expression}) {
	$PSBoundParameters.Expression = $_
	Measure-Script @PSBoundParameters
}
