
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
