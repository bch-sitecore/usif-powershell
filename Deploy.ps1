[CmdletBinding()]
Param(
  [Parameter(Position = 0, Mandatory = $true)]
  [string]$ApiKey
  ,
  [Parameter()]
  [string]$Repository = "PSGallery"
)
$ErrorActionPreference = "Stop"

$moduleName = "Unattended.SIF"
$modulePath = Convert-Path $PSScriptRoot\src\$moduleName

Publish-Module -Path $modulePath -NuGetApiKey $ApiKey -Repository $Repository

Write-Host "Deploy complete."