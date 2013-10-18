
<#
.Synopsis
	Counts properties grouped by names and types.
	Author: Roman Kuzmin

.Description
	The script counts objects grouped by types and their properties or entries
	grouped by names and types. Input objects should be piped to the script.

.Parameter CaseSensitive
	Tells to process names as case sensitive.

.Parameter DictionaryProperty
	Tells to count dictionary properties. By default dictionaries are treated
	as property bags, i.e. key/value pairs are counted instead of properties.

.Inputs
	Objects which properties or entries are to be counted.

.Outputs
	Custom objects with properties Name, Type, and Count.

.Link
	https://github.com/nightroman/PowerShelf
#>

param(
	[switch]$CaseSensitive,
	[switch]$DictionaryProperty
)

begin {
	if ($args) { Write-Error -ErrorAction Stop "Unknown arguments: $args" }

	function GetType($value) {
		if ($null -eq $value) {return '<null>'}
		$type = $value.GetType().Name

		if ($value -is [System.Collections.IDictionary]) {return "$type : IDictionary"}

		$value = [System.Management.Automation.LanguagePrimitives]::GetEnumerable($value)
		if ($null -eq $value -or $type.EndsWith('[]')) {$type}
		elseif ($value -is [System.Collections.IList]) {"$type : IList"}
		elseif ($value -is [System.Collections.ICollection]) {"$type : ICollection"}
		else {"$type : IEnumerable"}
	}

	$map = if ($CaseSensitive) { New-Object System.Collections.Hashtable } else { @{} }
}
process {
	# count object types
	++$map[".$(GetType $_)"]

	# count keys for dictionaries, properties for others
	if (!$DictionaryProperty -and ($dic = $_ -as [System.Collections.IDictionary])) {
		foreach($de in $dic.GetEnumerator()) {
			++$map["$($de.Key).$(GetType $de.Value)"]
		}
	}
	else {
		foreach($e in $_.PSObject.Properties) {
			try {
				$type = GetType $e.Value
			}
			catch {
				$type = '<error>'
			}
			++$map["$($e.Name).$type"]
		}
	}
}
end {
	foreach($_ in $map.GetEnumerator() | Sort-Object Key -CaseSensitive:$CaseSensitive) {
		if ($_.Key -match '^(.*)\.([^\.]+)$') {
			$r = 1 | Select-Object Name, Type, Count
			$r.Name = $matches[1]
			$r.Type = $matches[2]
			$r.Count = $_.Value
			$r
		}
	}
}
