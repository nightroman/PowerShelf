<#
.Synopsis
	Asserts current branch name and clean status.
	Author: Roman Kuzmin

.Description
	It fails on unexpected current branch name or not committed files.
	Requires git in the path.

.Parameter Branch
		The expected current branch name.
		Default: main

.Link
	https://github.com/nightroman/PowerShelf
#>

[CmdletBinding()]
param(
	[string]$Branch = 'main'
)

$ErrorActionPreference = 1; trap {$PSCmdlet.ThrowTerminatingError($_)}

$actualBranch = git branch --show-current 2>&1
if ($Global:LASTEXITCODE) {
	throw "git branch failed: $actualBranch"
}
if ($actualBranch -cne $Branch) {
	throw "Assertion failed: Expected branch: '$Branch', actual: '$actualBranch'."
}

$status = @(git status -s) 2>&1
if ($Global:LASTEXITCODE) {
	throw "git status failed: $status"
}
if ($status) {
	throw "Assertion failed: Expected 0 changes, actual: $($status.Count)."
}
