[CmdletBinding()]
Param(
  [Parameter(Position = 0, Mandatory = $true)]
  [string]$ApiKey
  ,
  [Parameter()]
  [string]$Repository = "PSGallery"
  ,
  [Parameter()]
  [switch]$Force
)
$ErrorActionPreference = "Stop"

$moduleName = "Unattended.SIF"
$modulePath = Convert-Path $PSScriptRoot\src\$moduleName

Publish-Module -Path $modulePath -NuGetApiKey $ApiKey -Repository $Repository -Force:$Force

Write-Host "Deploy complete."