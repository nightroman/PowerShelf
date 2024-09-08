<#PSScriptInfo
.VERSION 1.0.0
.AUTHOR Roman Kuzmin
.COPYRIGHT (c) Roman Kuzmin
.TAGS GraphQL Voyager
.GUID 9308d778-bfa3-4301-9ef8-db273bda2357
.LICENSEURI http://www.apache.org/licenses/LICENSE-2.0
.PROJECTURI https://github.com/nightroman/PowerShelf
#>

<#
.Synopsis
	Shows GraphQL schema using https://github.com/graphql-kit/graphql-voyager

.Description
	This command generates and opens HTML which renders GraphQL Voyager with
	the specified GraphQL API URL and several display options.

.Parameter ApiUrl
		Specifies the GraphQL API URL for introspection.

.Parameter RootType
		The root type name. Default: Query

.Parameter Output
		The output HTML file. The default is in the temp directory.

.Parameter HideDocs
		Tells to hide the docs sidebar.

.Parameter HideLeafFields
		Tells to hide all scalars and enums.

.Parameter HideSettings
		Tells to hide the settings panel.

.Parameter HideRoot
		Tells to hide the root type.

.Parameter ShowDeprecated
		Tells to show deprecated entities.

.Parameter ShowRelay
		Tells to show relay related types as is.

.Parameter SortByAlphabet
		Tells to sort fields on graph by alphabet.

.Link
	https://github.com/nightroman/PowerShelf
#>

[CmdletBinding()]
param(
	[Parameter(Position=0, Mandatory=1)]
	[Uri]$ApiUrl
	,
	[Parameter(Position=1)]
	[string]$RootType = 'Query'
	,
	[string]$Output
	,
	[switch]$HideDocs
	,
	[switch]$HideLeafFields
	,
	[switch]$HideSettings
	,
	[switch]$HideRoot
	,
	[switch]$ShowDeprecated
	,
	[switch]$ShowRelay
	,
	[switch]$SortByAlphabet
)

$ErrorActionPreference = 1

if ($RootType -notmatch '^\w+$') {
	throw "Invalid parameter RootType: $RootType"
}

### resolve output

if ($Output) {
	$Output = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($Output)
}
else {
	$Output = [System.IO.Path]::GetTempPath() + "GraphQLVoyager-$RootType.html"
}

### make HTML

function Get-Boolean($Value) {
	if ($Value) {'true'} else {'false'}
}

$html = @"
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
  	<title>$RootType $ApiUrl</title>

    <style>
      body {
        height: 100%;
        width: 100%;
        margin: 0;
        overflow: hidden;
      }

      #voyager {
        height: 100vh;
      }
    </style>

    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/graphql-voyager/dist/voyager.css">
    <script src="https://cdn.jsdelivr.net/npm/graphql-voyager/dist/voyager.standalone.js"></script>
  </head>

  <body>
    <div id="voyager">Loading...</div>
    <script type="module">
      const { voyagerIntrospectionQuery: query } = GraphQLVoyager;
      const response = await fetch(
        '$ApiUrl',
        {
          method: 'post',
          headers: {
            Accept: 'application/json',
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({ query }),
          credentials: 'omit',
        },
      );
      const introspection = await response.json();

      GraphQLVoyager.renderVoyager(document.getElementById('voyager'), {
        introspection,
        hideDocs: $(Get-Boolean $HideDocs),
        hideSettings: $(Get-Boolean $HideSettings),
        displayOptions: {
        	rootType: "$RootType",
        	hideRoot: $(Get-Boolean $HideRoot),
        	showLeafFields: $(Get-Boolean (!$HideLeafFields)),
        	skipDeprecated: $(Get-Boolean (!$ShowDeprecated)),
        	skipRelay: $(Get-Boolean (!$ShowRelay)),
        	sortByAlphabet: $(Get-Boolean $SortByAlphabet)
        },
      });
    </script>
  </body>
</html>
"@

### save and open HTML

[System.IO.File]::WriteAllText($Output, $html)
Invoke-Item -LiteralPath $Output
