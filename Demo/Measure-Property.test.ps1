
<#
.Synopsis
	Measure-Property.ps1 tests.
#>

task UnknownArguments {
	$ErrorActionPreference = 'Continue'
	($e = try {Measure-Property Bad1 Bad2} catch {$_ | Out-String})
	assert ($e -like "*Unknown arguments: Bad1 Bad2*At*\Measure-Property.test.ps1:*")
}

task ObjectProperty {
	# PSObject with Name and Version, both strings
	$ps1 = 1 | Select-Object Name, Version
	$ps1.Name = 'string'
	$ps1.Version = 'string'

	# another PSObject with Name and Version, both strings
	$ps2 = 1 | Select-Object Name, Version, Extra
	$ps2.Name = 'string'
	$ps2.Version = $Host.Version

	($r = $ps1, $ps2 | Measure-Property.ps1) | Out-String
	equals $r[0].Name ''
	equals $r[0].Type 'PSCustomObject'
	equals $r[0].Count 2
	equals $r[1].Name 'Extra'
	equals $r[1].Type '<null>'
	equals $r[1].Count 1
	equals $r[2].Name 'Name'
	equals $r[2].Type 'String'
	equals $r[2].Count 2
	equals $r[3].Name 'Version'
	equals $r[3].Type 'String'
	equals $r[3].Count 1
	equals $r[4].Name 'Version'
	equals $r[4].Type 'Version'
	equals $r[4].Count 1
}

# Process dictionaries as property bags
task DictionaryDefault {
	($r = @{p1=1; p2=2}, @{p1=2; p3=$null} | Measure-Property) | Out-String
	equals $r.Count 4
	equals $r[0].Name ''
	equals $r[0].Type 'Hashtable : IDictionary'
	equals $r[0].Count 2
	equals $r[1].Name 'p1'
	equals $r[1].Type 'Int32'
	equals $r[1].Count 2
	equals $r[2].Name 'p2'
	equals $r[1].Type 'Int32'
	equals $r[2].Count 1
	equals $r[3].Name 'p3'
	equals $r[3].Type '<null>'
	equals $r[3].Count 1
}

# Process dictionaries as standard objects
task DictionaryProperty {
	($r = @{p1=1; p2=2}, @() | Measure-Property -DictionaryProperty) | Out-String
	equals $r[0].Name ''
	equals $r[0].Type 'Hashtable : IDictionary'
	equals $r[0].Count 1
	equals $r[1].Name ''
	equals $r[1].Type 'Object[]'
	equals $r[1].Count 1
	equals $r[2].Name 'Count'
	equals $r[2].Type 'Int32'
	equals $r[2].Count 2
	equals $r[3].Name 'IsFixedSize'
	equals $r[3].Type 'Boolean'
	equals $r[3].Count 2
	equals $r[6].Name 'Keys'
	equals $r[6].Type 'KeyCollection : ICollection'
	equals $r[6].Count 1
}

# Test case sensitive names
task CaseSensitive {
	# data with mixed names
	$data = @{n=1}, @{N=1}

	# default is ignore case
	($r = $data | Measure-Property) | Out-String
	equals $r.Count 2
	equals $r[1].Name 'n'
	equals $r[1].Count 2

	# case sensitive
	($r = $data | Measure-Property -CaseSensitive) | Out-String
	equals $r.Count 3
	equals $r[1].Name 'n'
	equals $r[1].Count 1
	equals $r[2].Name 'N'
	equals $r[2].Count 1
}

task Types {
	Add-Type @'
using System.Collections;
public static class TestEnumerable {
	public static IEnumerable Get() {
		yield return 1;
		yield return 1;
	}
}
'@
	$r = @{
		p1_Array = @()
		p2_IList = [Collections.ArrayList]@()
		p3_ICollection = @{}.Keys
		p4_IEnumerable = [TestEnumerable]::Get()
	} | Measure-Property
	$r | Out-String
	equals $r[0].Type 'Hashtable : IDictionary'
	equals $r[1].Type 'Object[]'
	equals $r[2].Type 'ArrayList : IList'
	equals $r[3].Type 'KeyCollection : ICollection'
	if ($PSVersionTable.PSVersion.Major -ge 3) {
		assert ($r[4].Type -like '* : IEnumerable')
	}
}
