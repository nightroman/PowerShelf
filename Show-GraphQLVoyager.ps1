<#PSScriptInfo
.VERSION 0.0.2
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

	The GraphQL Voyager .css and .js files are downloaded once to the cache.
	Remove them in order to get the latest versions. The cache directory:
	$HOME/.PowerShelf/Show-GraphQLVoyager

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
$ProgressPreference = 0

if ($RootType -notmatch '^\w+$') {
	Write-Error "Invalid parameter RootType: $RootType"
}

### resolve output

if ($Output) {
	$Output = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($Output)
}
else {
	$Output = [System.IO.Path]::GetTempPath() + "GraphQLVoyager-$RootType.html"
}

### cache resources

$cache = "$HOME/.PowerShelf/Show-GraphQLVoyager"
$null = mkdir $cache -Force

$css = "$cache/voyager.css"
if (![System.IO.File]::Exists($css)) {
	Write-Host "Downloading $css"
	Invoke-WebRequest -Uri https://cdn.jsdelivr.net/npm/graphql-voyager/dist/voyager.css -OutFile $css
}

$js = "$cache/voyager.standalone.js"
if (![System.IO.File]::Exists($js)) {
	Write-Host "Downloading $js"
	Invoke-WebRequest -Uri https://cdn.jsdelivr.net/npm/graphql-voyager/dist/voyager.standalone.js -OutFile $js
}

### make HTML

function Get-FileUrl([string]$Path) {
	'file:///' + $Path.Replace('\', '/')
}

function Get-Boolean($Value) {
	if ($Value) {'true'} else {'false'}
}

$html = @"
<!doctype html>
<html>
  <head>
    <style>
      body {
        height: 100%;
        margin: 0;
        width: 100%;
        overflow: hidden;
      }

      #voyager {
        height: 100vh;
      }
    </style>

    <link rel="stylesheet" href="$(Get-FileUrl $css)" />
    <script src="$(Get-FileUrl $js)"></script>
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
