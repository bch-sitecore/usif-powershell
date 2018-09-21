[CmdletBinding()]
Param(
  [Parameter(Position = 0, Mandatory = $true)]
  [string]$ApiKey
  ,
  [Parameter(Position = 0)]
  [string]$Repository = "PSGallery"
)
$ErrorActionPreference = "Stop"

$moduleName = "Unattended.SIF"
$modulePath = Convert-Path $PSScriptRoot\src\$moduleName

Publish-Module -Path $modulePath -NuGetApiKey $ApiKey -Repository $PublishRepository

Write-Host "Deploy complete."