[CmdletBinding()]
Param(
  [Parameter()]
  [string]$PublishRepository = "http://bchnuget.azurewebsites.net/nuget"
)
$ErrorActionPreference = "Stop"

$osVersion = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").BuildLabEx
Write-Host "Server version ${osVersion}"

$psVersion = $PSVersionTable.PSVersion
Write-Host "PowerShell version ${psVersion}"

If ($null -ne (Get-Command "docker" -ErrorAction SilentlyContinue)) {
  docker version
}

Install-PackageProvider -Name "NuGet" -Force

@(
  @{ Name = "Pester";           MinimumVersion = [version]"4.4" }
  @{ Name = "PSScriptAnalyzer"; MinimumVersion = [version]"1.17" }
  @{ Name = "PowerShellGet";    MinimumVersion = [version]"1.6" }
) | ForEach-Object {
  $moduleName = $_.Name
  $minVersion = $_.MinimumVersion

  $existing = Get-Module $moduleName -ListAvailable -ErrorAction SilentlyContinue
  If (!$existing -or $existing.Version -lt $minVersion) {
    Install-Module $moduleName -MinimumVersion $minVersion -SkipPublisherCheck -Force
    Import-Module $moduleName -MinimumVersion $minVersion
  }
}

# No way to automate this--ugh. Should be enough to Update-Module, but, alas, nope.
If ($null -eq (Get-Command "nuget" -ErrorAction SilentlyContinue)) {
  $nuget = "C:\Users\bch\AppData\Local\Microsoft\Windows\PowerShell\PowerShellGet\nuget.exe"
  If (!(Test-Path $nuget)) {
    Invoke-WebRequest "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe" -OutFile $nuget -UseBasicParsing
  }
}