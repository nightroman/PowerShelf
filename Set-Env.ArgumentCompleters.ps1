<#
.Synopsis
	Completes Set-Env.ps1 -Name, -Value .
	Author: Roman Kuzmin

.Description
	`Name` is completed with environment variable names.
	`Value` is completed with the current location item paths.

.Link
	Register-ArgumentCompleter

.Link
	https://github.com/nightroman/PowerShelf
#>

Register-ArgumentCompleter -CommandName Set-Env.ps1 -ParameterName Name -ScriptBlock {
	param($commandName, $parameterName, $wordToComplete, $commandAst, $boundParameters)

	Get-Item env:\$wordToComplete* -ErrorAction 0 | .{process{
		[System.Management.Automation.CompletionResult]::new($_.Name, $_.Name, 'Variable', $_.Value)
	}}
}

Register-ArgumentCompleter -CommandName Set-Env.ps1 -ParameterName Value -ScriptBlock {
	param($commandName, $parameterName, $wordToComplete, $commandAst, $boundParameters)

	# current folder
	if (!$wordToComplete) {
		$_ = @(Get-Item . -ErrorAction 0)
		if ($_.Count -eq 1) {
			[System.Management.Automation.CompletionResult]::new($_.FullName, '.', 'ProviderContainer', $_.FullName)
		}
	}

	# current items
	Get-Item $wordToComplete* -ErrorAction 0 | .{process{
		if ($_ -is [System.IO.FileInfo]) {
			[System.Management.Automation.CompletionResult]::new($_.FullName, $_.Name, 'ProviderItem', $_.FullName)
		}
		elseif ($_ -is [System.IO.DirectoryInfo]) {
			[System.Management.Automation.CompletionResult]::new($_.FullName, $_.Name, 'ProviderContainer', $_.FullName)
		}
	}}
}
