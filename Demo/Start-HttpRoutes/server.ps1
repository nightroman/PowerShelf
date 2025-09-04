<#
.Synopsis
	How to use Start-HttpRoutes and define routes.
#>

Start-HttpRoutes http://127.0.0.1:9999 @{
	# Gets $PID. We use it in tests to stop this process.
	'GET /' = {
		$PID
	}

	# Wildcard path.
	'GET /test/*' = {
		$Request.Url.AbsolutePath
	}

	# Adds numbers and gets text result.
	'POST /add/text' = {
		$Query = Get-Query
		[int]$Query.A + [int]$Query.B
	}

	# Adds numbers and gets JSON result.
	'POST /add/json' = {
		$Response.ContentType = 'application/json'
		$Query = Get-Query
		@{
			Result = [int]$Query.A + [int]$Query.B
			Errors = @()
		} | ConvertTo-Json
	}

	# Uses Read-Content, Get-Headers, Get-Query.
	'POST /show' = {
		$Response.ContentType = 'application/json'
		[ordered]@{
			Headers = Get-Headers
			Query = Get-Query
			Data = ConvertFrom-Json (Read-Content)
		} | ConvertTo-Json -Depth 99
	}
}
