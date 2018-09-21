[CmdletBinding()]
Param(
  [Parameter(Mandatory = $true)]
  [string]$ApiKey
  ,
  [Parameter()]
  [string]$Repository = "PSGallery"
)
$ErrorActionPreference = "Stop"

$moduleName = "Unattended.SIF"
$modulePath = Convert-Path $PSScriptRoot\src\$moduleName

Publish-Module -Path $modulePath -NuGetApiKey $ApiKey -Repository $PublishRepository

Write-Host "Deploy complete."