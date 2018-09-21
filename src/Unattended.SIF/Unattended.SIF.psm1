$Public  = @( Get-ChildItem $PSScriptRoot\Public\*.ps1 -Exclude "*.Tests.ps1" -Recurse -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem $PSScriptRoot\Private\*.ps1 -Exclude "*.Tests.ps1" -Recurse -ErrorAction SilentlyContinue )

@($Public + $Private) | ForEach-Object {
  $script = $_.FullName
  Try {
    Write-Verbose "Loading ${script}"
    . $script
  } Catch {
    $errorMessage = $_.Exception.Message
    Write-Error "Unable to load ${script}, ${errorMessage}"
  }
}

Export-ModuleMember -Function $Public.BaseName