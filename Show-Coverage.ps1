
<#
.Synopsis
	Converts to HTML and shows script coverage data.
	Author: Roman Kuzmin

.Description
	This script converts script coverage data produced by Trace-Debugger.ps1 to
	a HTML file and opens it by an associated application, normally the default
	internet browser.

	Coverage information is not always accurate because a tracing tool may not
	step through all pieces of code and this script does not perform detailed
	analysis of sources.

.Parameter Data
		A hashtable with coverage data, e.g. produced by Trace-Debugger.ps1.
.Parameter Html
		Specifies the output HTML file.
		Default: $env:TEMP\Coverage.htm
.Parameter Show
		Specifies the script block which opens the converted HTML file. The
		default script { Invoke-Item -LiteralPath $args[0] } opens it by the
		associated application, normally the default browser.

.Inputs
	None
.Outputs
	None

.Example
	>
	How to collect and show script coverage data

	# enable tracing with result data table
	Trace-Debugger Test.ps1 -Table Coverage

	# invoke with tracing
	Test.ps1

	# stop tracing
	Restore-Debugger

	# show coverage data
	Show-Coverage $Coverage

.Link
	https://github.com/nightroman/PowerShelf
.Link
	Trace-Debugger.ps1
#>

param(
	[Parameter(Mandatory=1)]
	[hashtable]$Data,
	[string]$Html = "$env:TEMP\Coverage.htm",
	[scriptblock]$Show = {Invoke-Item -LiteralPath $args[0]}
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

# HtmlEncode
Add-Type -AssemblyName System.Web

function encode($Text) {
	[System.Web.HttpUtility]::HtmlEncode($text)
}

function convert($Path, $Data) {
	$lines = Get-Content -LiteralPath $Path

	[ref]$bugs = $null
	$tokens = [System.Management.Automation.PSParser]::Tokenize($lines, $bugs)
	if ($bugs.Value.Count) {
		$can = $null
	}
	else {
		$can = @{}
		foreach($token in $tokens) {
			switch($token.Type) {
				Attribute          {$yes = 0; break}
				Command            {$yes = 1; break}
				CommandArgument    {$yes = 0; break}
				CommandParameter   {$yes = 0; break}
				Comment            {$yes = 0; break}
				GroupEnd           {$yes = 0; break}
				GroupStart         {$yes = 0; break}
				Keyword            {$yes = 0; break}
				LineContinuation   {$yes = 0; break}
				LoopLabel          {$yes = 0; break}
				Member             {$yes = 1; break}
				NewLine            {$yes = 0; break}
				Number             {$yes = 1; break}
				Operator           {$yes = 0; break}
				Position           {$yes = 1; break}
				StatementSeparator {$yes = 0; break}
				String             {$yes = 1; break}
				Type               {$yes = 1; break}
				Variable           {$yes = 1; break}
				default            {$yes = 1; break}
			}
			if ($yes) {
				++$can[$token.StartLine]
			}
		}
	}

	'<pre>'
	$n = 0
	foreach($line in $lines) {
		++$n

		$line = $line.TrimEnd()
		if (!$line) {
			'{0,5}       : ' -f $n
			continue
		}

		if (!($pass = $Data[$n])) {
			if (!$can -or $can[$n]) {
				$pass = '---->'
			}
			else {
				$pass = '     '
			}
		}
		'{0,5} {1,5} :  {2}' -f $n, $pass, (encode $line)
	}
	'</pre>'
}

### generate
.{
	'<html><title>Coverage</title>'
	'<body>'

	$paths = $Data.Keys | Sort-Object

	### index
	'<h3>Covered Scripts</h3>'
	'<ul>'
	$n = 0
	foreach($path in $paths) { if (Test-Path -LiteralPath $path) {
		++$n
		"<li><a href='#file$n'>$(encode $path)</a></li>"
	}}
	'</ul>'

	### content
	$n = 0
	foreach($path in $paths) { if (Test-Path -LiteralPath $path) {
		++$n
		"<hr/><h3><a id='file$n'>$(encode $path)</a></h3>"
		convert $path $Data[$path]
	}}

	'</body>'
	'</html>'
} | Set-Content -LiteralPath $Html -Encoding UTF8

### show
if ($Show) {
	& $Show $Html
}
