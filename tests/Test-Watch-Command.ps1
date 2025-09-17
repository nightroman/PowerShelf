
<#
.Synopsis
	Watch-Command.ps1 test.

.Description
	This test is manual. How to test:

	It starts with the maximum not truncated line number. The last line should
	not be *. Increase/decrease window/buffer size manually and ensure it works
	fine. The last * line should appear on decreasing.

	It generates lines longer and shorter than the window width randomly. Only
	.... or XXXX lines are shown each time. They should never be shown mixed.
#>

$r = [random]0
$a = @('X', '.')
$wh = $Host.UI.RawUI.WindowSize.Height - 9
Watch-Command.ps1 {
	netstat -e
	$s = $a[$r.Next(2)]
	for($i = 1; $i -le $wh; ++$i) {
		"$i $(Get-Date) $($s*$r.Next(200))"
	}
} 1
