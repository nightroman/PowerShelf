
<#
.Synopsis
	Sets the current console size, interactively by default.
	Author: Roman Kuzmin

.Description
	The script allows resizing of the current console either interactively by
	arrow keys (other keys stop resizing) or by specifying Width and/or Height.

	The buffer width is always set equal to window width. The buffer height is
	set equal to width if it was initially equal or not changed otherwise.

.Parameter Width
		New console width. Default is 0 (the current).
.Parameter Height
		New console height. Default is 0 (the current).

.Inputs
	None.
.Outputs
	None.

.Example
	Set-ConsoleSize.ps1
	Starts interactive resizing with arrow keys.

.Example
	Set-ConsoleSize.ps1 80 25
	Sets classic small console size.

.Example
	Set-ConsoleSize.ps1 80
	Sets only new width.

.Link
	https://github.com/nightroman/PowerShelf
#>

param($Width = 0, $Height = 0)
$ErrorActionPreference = 0

$UI = $Host.UI.RawUI
$eq = $UI.BufferSize -eq $UI.WindowSize

function NewSize($Width, $Height)
{
	New-Object System.Management.Automation.Host.Size $Width, $Height
}

function SetSize($Width, $Height)
{
	# reduce width
	if ($Width -lt $UI.WindowSize.Width -and $Width -gt 0) {
		$UI.WindowSize = NewSize $Width $UI.WindowSize.Height
		$UI.BufferSize = NewSize $Width $UI.BufferSize.Height
	}
	# increase width
	elseif ($Width -gt $UI.WindowSize.Width) {
		$UI.BufferSize = NewSize $Width $UI.BufferSize.Height
		$UI.WindowSize = NewSize $Width $UI.WindowSize.Height
	}

	# reduce height
	if ($Height -lt $UI.WindowSize.Height -and $Height -gt 0) {
		$UI.WindowSize = NewSize $UI.WindowSize.Width $Height
		if ($eq) {
			$UI.BufferSize = $UI.WindowSize
		}
	}
	# increase height
	elseif ($Height -gt $UI.WindowSize.Height) {
		if ($Height -gt $UI.BufferSize.Height) {
			$UI.BufferSize = NewSize $UI.BufferSize.Width $Height
		}
		$UI.WindowSize = NewSize $UI.WindowSize.Width $Height
	}

	# sync buffer
	if ($eq -and ($UI.BufferSize -ne $UI.WindowSize)) {
		$UI.BufferSize = $UI.WindowSize
	}
}

### Set the specified size
if ($Width -gt 0 -or $Height -gt 0) {
	SetSize $Width $Height
	return
}

### Interactive sizing
$title = $UI.WindowTitle
for(;;) {
	$UI.WindowTitle = '{0} x {1} Arrow keys: resize; other keys: exit ...' -f $UI.WindowSize.Width, $UI.WindowSize.Height
	switch($UI.ReadKey(6).VirtualKeyCode) {
		37 {
			SetSize ($UI.WindowSize.Width - 1) $UI.WindowSize.Height
			break
		}
		39 {
			SetSize ($UI.WindowSize.Width + 1) $UI.WindowSize.Height
			break
		}
		38 {
			SetSize $UI.WindowSize.Width ($UI.WindowSize.Height - 1)
			break
		}
		40 {
			SetSize $UI.WindowSize.Width ($UI.WindowSize.Height + 1)
			break
		}
		default {
			$UI.WindowTitle = $title
			return
		}
	}
}
