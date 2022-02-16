
task Add {
	remove a, b

	Expand-Diff.ps1 Test-Add.diff

	$r = @(Get-ChildItem a -Recurse -Force)
	equals $r.Count 0

	$r = @(Get-ChildItem b -Recurse -Force)
	equals $r.Count 1
	equals $r[0].FullName "$BuildRoot\b\1.txt"
	equals (Get-Content b\1.txt) '1'

	remove a, b
}

task Delete {
	remove a, b

	Expand-Diff.ps1 Test-Delete.diff

	$r = @(Get-ChildItem a -Recurse -Force)
	equals $r.Count 1
	equals $r[0].FullName "$BuildRoot\a\1.txt"
	equals (Get-Content a\1.txt) '1'

	$r = @(Get-ChildItem b -Recurse -Force)
	equals $r.Count 0

	remove a, b
}

task Rename {
	remove a, b

	Expand-Diff.ps1 Test-Rename.diff

	$r = @(Get-ChildItem a -Recurse -Force)
	equals $r.Count 1
	equals $r[0].FullName "$BuildRoot\a\1.txt"
	equals (Get-Content a\1.txt) '2'

	$r = @(Get-ChildItem b -Recurse -Force)
	equals $r.Count 1
	equals $r[0].FullName "$BuildRoot\b\2.txt"
	equals (Get-Content b\2.txt) '2'

	remove a, b
}

task Change {
	remove a, b

	Expand-Diff.ps1 Test-Change.diff

	$r = @(Get-ChildItem a -Recurse -Force)
	equals $r.Count 1
	equals $r[0].FullName "$BuildRoot\a\файл.txt"
	equals ((Get-Content a\файл.txt -Encoding UTF8) -join '|') '@@ -1,5 +1,5 @@|мой|дядя|самый|честных|правил'

	$r = @(Get-ChildItem b -Recurse -Force)
	equals $r.Count 1
	equals $r[0].FullName "$BuildRoot\b\файл.txt"
	equals ((Get-Content b\файл.txt -Encoding UTF8) -join '|') '@@ -1,5 +1,5 @@|мой|дядя|самых|честных|правил'

	remove a, b
}

task Reversed {
	remove a, b

	Expand-Diff.ps1 Test-Reversed.diff

	$r = @(Get-ChildItem a -Recurse -Force)
	equals $r.Count 1
	equals $r[0].FullName "$BuildRoot\a\Test.txt"
	equals ((Get-Content a\Test.txt -Encoding UTF8) -join '|') '@@ -1,3 +1,2 @@|Line1|Line2'

	$r = @(Get-ChildItem b -Recurse -Force)
	equals $r.Count 1
	equals $r[0].FullName "$BuildRoot\b\Test.txt"
	equals ((Get-Content b\Test.txt -Encoding UTF8) -join '|') '@@ -1,3 +1,2 @@|Line1|added|Line2'

	remove a, b
}

# fixed regex with paths and trailing tabs
task Test-x_220216_trailing_tabs.diff {
	remove a, b

	Expand-Diff.ps1 Test-x_220216_trailing_tabs.diff

	$r = @(Get-ChildItem a, b -Recurse -Force -File)
	equals $r.Count 2
	equals $r[0].FullName "$BuildRoot\a\repo\file.cs"
	equals $r[1].FullName "$BuildRoot\b\repo\file.cs"

	$r1 = ($r[0] | Get-Content) -join '|'
	equals $r1 '@@ -20,6 +20,8 @@ namespace My.Namespace||        int OrderQuantity { get; }||        IEnumerable Solutions { get; }|    }|}'

	$r2 = ($r[1] | Get-Content) -join '|'
	equals $r2 '@@ -20,6 +20,8 @@ namespace My.Namespace||        int OrderQuantity { get; }||        string UniqueId { get; }||        IEnumerable Solutions { get; }|    }|}'

	remove a, b
}
