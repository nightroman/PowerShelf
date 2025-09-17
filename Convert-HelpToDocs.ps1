<#
.Synopsis
	Converts command help to markdown docs.
	Author: Roman Kuzmin

.Description
	It gets and converts the command help to markdown.

	Default output is markdown text.
	Use OutFile to save it.

.Parameter Command
		The command name.

.Parameter OutFile
		Optional output file path.

.Link
	https://github.com/nightroman/PowerShelf
#>

[CmdletBinding()]
param(
	[Parameter(Position=0, Mandatory=1)]
	[string]$Command
	,
	[Parameter(Position=1)]
	[string]$OutFile
)

Set-StrictMode -Version 3
$ErrorActionPreference = 1

$r = Get-Help -Name $Command -Full
$n = "`n"

$Name = $r.Name
if ($Name -like '*.ps1') {
	$Name = Split-Path $r.Name -Leaf
}

$text = $(
	### Heading
	'# {0}' -f $Name

	### Synopsis
	'{0}```text{0}{1}{0}```' -f $n, $r.Synopsis

	### Syntax
	'{0}## Syntax' -f $n
	$many = foreach($_ in $r.Syntax) { foreach ($_ in $_.syntaxItem) {
		$parameter = $_.PSObject.Properties['parameter']
		if ($parameter) {
			'{0}```text' -f $n
			$s = $Name
			foreach($p in $parameter.Value) {
				$s += ' '
				if ($p.required -eq 'false') {$s += '['}

				if ($p.position -ne 'named') {$s += '['}
				$s += '-' + $p.name
				if ($p.position -ne 'named') {$s += ']'}

				if ($x = $p.PSObject.Properties['parameterValue']) {$s += ' ' + $x.Value}

				if ($p.required -eq 'false') {$s += ']'}
			}
			$s
			'```'
		}
		else {
			# parameter set with no parameters
			'{0}```text{0}{1}{0}```' -f $n, $Name
		}
	}}
	if ($many) {
		$many
	}
	else {
		# command with no parameters
		'{0}```text{0}{1}{0}```' -f $n, $Name
	}

	### Description
	$many = foreach($_ in $r.Description) {
		$_.Text
	}
	if ($many) {
		'{0}## Description{0}{0}```text' -f $n
		$many
		'```'
	}

	### Parameters
	$parameter = $r.Parameters.PSObject.Properties['parameter']
	if ($parameter) {
		$many = foreach($_ in $parameter.Value) {
			'{0}```text' -f $n
			$lines = ($_ | Out-String).Trim() -split "`r?`n"
			foreach($line in $lines) {
				if ($line.Trim() -notin 'Default value', 'Accept pipeline input?', 'Aliases', 'Accept wildcard characters?') {
					$line
				}
			}
			'```'
		}
		if ($many) {
			'{0}## Parameters' -f $n
			$many
		}
	}

	### Inputs
	if ($x = $r.PSObject.Properties['inputTypes']) {
		'{0}## Inputs' -f $n
		foreach($_ in $x.Value) { foreach($_ in $_.inputType) {
			'{0}```text' -f $n
			'{0}' -f $_.type.name
			if ($description = $_.PSObject.Properties['description']) {
				'{0}' -f ($description.Value.text -replace '(?m)^(?!\s)', '    ')
			}
		}}
		'```'
	}

	### Outputs
	if ($x = $r.PSObject.Properties['returnValues']) {
		'{0}## Outputs' -f $n
		foreach($_ in $x.Value) { foreach($_ in $_.returnValue) {
			'{0}```text' -f $n
			'{0}' -f $_.type.name
			if ($description = $_.PSObject.Properties['description']) {
				'{0}' -f ($description.Value.text -replace '(?m)^(?!\s)', '    ')
			}
			'```'
		}}
	}

	### Notes
	$alertSet = $r.PSObject.Properties['alertSet']
	if ($alertSet) {
		'{0}## Notes{0}```text' -f $n
		foreach($_ in $alertSet.Value) { foreach($_ in $_.alert) {
			$_.Text
		}}
		'```'
	}

	### Examples
	#! no remarks? out just code with no prompt
	$examples = $r.PSObject.Properties['examples']
	if ($examples) {
		$many = foreach($_ in $examples.Value) { foreach($_ in $_.example) {
			'{0}```text' -f $n
			$_.title

			$remarks = $_.PSObject.Properties['remarks']
			if ($remarks) {
				$remarks = foreach($remark in $remarks.Value) {
					if ($s = $remark.Text.Trim()) {$s}
				}
			}

			$code = $_.code
			if ($code -and $remarks) {
				if ($code.Contains("`n")) {
					'PS>'
					$code
				}
				else {
					'PS> {0}' -f $code
				}
			}
			else {
				$code
			}

			if ($remarks) {
				''
				$remarks
			}

			'```'
		}}
		if ($many) {
			'{0}## Examples' -f $n
			$many
		}
	}

	### Links
	$relatedLinks = $r.PSObject.Properties['relatedLinks']
	if ($relatedLinks) {
		$many = foreach($_ in $relatedLinks.Value) { foreach($_ in $_.navigationLink) {
			$s = ''
			if ($linkText = $_.PSObject.Properties['linkText']) {
				$s = $linkText.Value
			}
			if ($uri = $_.PSObject.Properties['uri']) {
				if ($s) {$s = $s + ' '}
				$s += $uri.Value
			}
			if ($s) {$s}
		}}
		if ($many) {
			'{0}## Links{0}{0}```text' -f $n
			$many
			'```'
		}
	}

	''
) -join $n -replace '\r\n', $n

if ($OutFile) {
	Set-Content -LiteralPath $OutFile -Value $text -NoNewline
}
else {
	$text
}
