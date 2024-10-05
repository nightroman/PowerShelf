<#PSScriptInfo
.VERSION 2.0.0
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
	This command generates and opens HTML which renders GraphQL Voyager
	with the specified GraphQL schema file or URL for introspection and
	several display options.

.Parameter Schema
		Specifies the GraphQL schema file or URL for introspection.

.Parameter RootType
		The root type name.

.Parameter Output
		Tells to output HTML to the specified file. If this parameter is
		omitted then the temp file "GraphQLVoyager.html" is used and on
		Windows automatically opened.

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
		Tells to show relay types literally.

.Parameter SortByAlphabet
		Tells to sort type fields by alphabet.

.Link
	https://github.com/nightroman/PowerShelf
#>

[CmdletBinding()]
param(
	[Parameter(Position=0, Mandatory=1)]
	[string]$Schema
	,
	[Parameter(Position=1)]
	[string]$RootType
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

### Schema

if ($Schema -match '^\w\w+://') {
	$sdl = $null
}
else {
	$sdl = [System.IO.File]::ReadAllText($PSCmdlet.GetUnresolvedProviderPathFromPSPath($Schema))
}

### RootType

if ($RootType) {
	if ($RootType -notmatch '^\w+$') {
		throw "Invalid parameter RootType: '$RootType'."
	}
	$title = "$RootType $Schema"
}
else {
	$title = $Schema
}

### Output

if ($Output) {
	$toShow = $false
	$Output = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($Output)
}
else {
	$toShow = $PSVersionTable['Platform'] -ne 'Unix'
	$Output = [System.IO.Path]::GetTempPath() + 'GraphQLVoyager.html'
}

### make HTML

function Get-Boolean($Value) {
	if ($Value) {'true'} else {'false'}
}

$html = $(
	@"
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
  	<title>$title</title>
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
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/graphql-voyager/dist/voyager.css"/>
    <script src="https://cdn.jsdelivr.net/npm/graphql-voyager/dist/voyager.standalone.js"></script>
  </head>
  <body>
    <div id="voyager">Loading...</div>
    <script type="module">
      const escapeHtml = (html) => {
        return html.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;').replaceAll('"', '&quot;').replaceAll("'", '&#039;');
      }
      const voyager = document.getElementById('voyager');
      try {
"@

	if ($sdl) {
		@"
        const sdl = ``$($sdl.Replace('\', '\\').Replace('${', '\${').Replace('`', '\`'))``
        const { sdlToSchema: sdlToIntrospection } = GraphQLVoyager;
        const introspection = sdlToIntrospection(sdl);
"@
	}
	else {
		@"
        const { voyagerIntrospectionQuery: query } = GraphQLVoyager;
        const response = await fetch(
          '$($Schema.Replace("'", "\'"))',
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
"@
	}

	@"
        GraphQLVoyager.renderVoyager(voyager, {
          introspection,
          hideDocs: $(Get-Boolean $HideDocs),
          hideSettings: $(Get-Boolean $HideSettings),
          displayOptions: {
            rootType: $(if ($RootType) {"'$RootType'"} else {'null'}),
            hideRoot: $(Get-Boolean $HideRoot),
            showLeafFields: $(Get-Boolean (!$HideLeafFields)),
            skipDeprecated: $(Get-Boolean (!$ShowDeprecated)),
            skipRelay: $(Get-Boolean (!$ShowRelay)),
            sortByAlphabet: $(Get-Boolean $SortByAlphabet),
          },
        });
      }
      catch(error) {
        voyager.innerHTML = ``<pre>`${escapeHtml(error.toString())}</pre>``;
      }
    </script>
  </body>
</html>
"@
) -join "`n"

### save and open HTML

[System.IO.File]::WriteAllText($Output, $html)
if ($toShow) {
	Invoke-Item -LiteralPath $Output
}
