
<#
.Synopsis
	Measure-Property.ps1 tests.
#>

task UnknownArguments {
	$ErrorActionPreference = 'Continue'
	$err = ''
	try { Measure-Property Bad1 Bad2 }
	catch { $err = $_ | Out-String }
	assert ($err -like "*Unknown arguments: Bad1 Bad2*At*\Measure-Property.test.ps1:*")
}

task ObjectProperty {
	# PSObject with Name and Version, both strings
	$ps = 1 | Select-Object Name, Version
	$ps.Name = 'string'
	$ps.Version = 'string'

	# Two objects, $host also has Name and Version, Version is not string
	$r = $Host, $ps | Measure-Property.ps1
	$r
	assert ($r[0].Name -eq '' -and $r[0].Type -eq 'InternalHost' -and $r[0].Count -eq 1)
	assert ($r[1].Name -eq '' -and $r[1].Type -eq 'PSCustomObject' -and $r[1].Count -eq 1)
	assert ($r[6].Name -eq 'Name' -and $r[6].Type -eq 'String' -and $r[6].Count -eq 2)
	assert ($r[-2].Name -eq 'Version' -and $r[-2].Type -eq 'String' -and $r[-2].Count -eq 1)
	assert ($r[-1].Name -eq 'Version' -and $r[-1].Type -eq 'Version' -and $r[-1].Count -eq 1)
}

# Process dictionaries as property bags
task DictionaryDefault {
	$r = @{p1=1; p2=2}, @{p1=2; p3=$null} | Measure-Property
	$r
	assert ($r.Count -eq 4)
	assert ($r[0].Name -eq '' -and $r[0].Type -eq 'Hashtable : IDictionary' -and $r[0].Count -eq 2)
	assert ($r[1].Name -eq 'p1' -and $r[1].Type -eq 'Int32' -and $r[1].Count -eq 2)
	assert ($r[2].Name -eq 'p2' -and $r[1].Type -eq 'Int32' -and $r[2].Count -eq 1)
	assert ($r[3].Name -eq 'p3' -and $r[3].Type -eq '<null>' -and $r[3].Count -eq 1)
}

# Process dictionaries as standard objects
task DictionaryProperty {
	$r = @{p1=1; p2=2}, @() | Measure-Property -DictionaryProperty
	$r
	assert ($r[0].Name -eq '' -and $r[0].Type -eq 'Hashtable : IDictionary' -and $r[0].Count -eq 1)
	assert ($r[1].Name -eq '' -and $r[1].Type -eq 'Object[]' -and $r[1].Count -eq 1)
	assert ($r[2].Name -eq 'Count' -and $r[2].Type -eq 'Int32' -and $r[2].Count -eq 2)
	assert ($r[3].Name -eq 'IsFixedSize' -and $r[3].Type -eq 'Boolean' -and $r[3].Count -eq 2)
	assert ($r[6].Name -eq 'Keys' -and $r[6].Type -eq 'KeyCollection : ICollection' -and $r[6].Count -eq 1)
}

# Test case sensitive names
task CaseSensitive {
	# data with mixed names
	$data = @{n=1}, @{N=1}

	# default is ignore case
	$r = $data | Measure-Property
	$r
	assert ($r.Count -eq 2 -and $r[1].Name -ceq 'n' -and $r[1].Count -eq 2)

	# case sensitive
	$r = $data | Measure-Property -CaseSensitive
	$r
	assert ($r.Count -eq 3 -and $r[1].Name -ceq 'n' -and $r[1].Count -eq 1 -and $r[2].Name -ceq 'N' -and $r[2].Count -eq 1)
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
	$r
	assert ($r[0].Type -eq 'Hashtable : IDictionary')
	assert ($r[1].Type -eq 'Object[]')
	assert ($r[2].Type -eq 'ArrayList : IList')
	assert ($r[3].Type -eq 'KeyCollection : ICollection')
	if ($PSVersionTable.PSVersion.Major -ge 3) {
		assert ($r[4].Type -like '* : IEnumerable')
	}
}
