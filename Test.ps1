[CmdletBinding()]
Param(
  [switch]$IncludePrivate
)
$ErrorActionPreference = "Stop"

$moduleName = "Unattended.SIF"
$modulePath = Convert-Path $PSScriptRoot\src\$moduleName
Write-Verbose "Loading ${moduleName} from ${modulePath}"

Remove-Module $moduleName -Force -ErrorAction SilentlyContinue
Import-Module $modulePath -Scope Local

If ($IncludePrivate) {
  Get-ChildItem $modulePath\Private\*.ps1 -Exclude "*.Tests.ps1" -ErrorAction SilentlyContinue | ForEach-Object {
    $script = $_.FullName
    Write-Verbose "Loading ${script}"
    . $script
  }
}

Invoke-Pester .\test