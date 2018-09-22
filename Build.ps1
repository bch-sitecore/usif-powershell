[CmdletBinding()]
Param(
  [Parameter(Position = 0)]
  [Alias("Version")]
  [version]$ModuleVersion = $null
)
$ErrorActionPreference = "Stop"

$moduleName = "Unattended.SIF"
$modulePath = Convert-Path $PSScriptRoot\src\$moduleName
$moduleManifest = Convert-Path $PSScriptRoot\src\$moduleName\$moduleName.psd1

$manifest = Test-ModuleManifest $ModuleManifest
If ($ModuleVersion) {
  $version = $manifest.Version
  $moduleVersion = New-Object System.Version $version.Major, $version.Minor, ($version.Build + 1)
}

$functionsToExport = ( Get-ChildItem $modulePath\Public\*.ps1 -Exclude "*.Tests.ps1" -Recurse -ErrorAction SilentlyContinue ).BaseName
Update-ModuleManifest $moduleManifest -ModuleVersion $moduleVersion -FunctionsToExport $functionsToExport

Test-ModuleManifest $moduleManifest

Write-Host "Build complete."