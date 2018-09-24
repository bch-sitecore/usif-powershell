<#
  .SYNOPSIS
    Installs Internet Information Services (IIS)
#>
Function Install-IIS {
  [CmdletBinding(SupportsShouldProcess = $true)]
  Param()
  Begin {
    $isServer = $null -ne (Get-Command Install-WindowsFeature -ErrorAction SilentlyContinue)
    $isInstalled = If ($isServer) { (Get-WindowsFeature "Web-Server").Installed }
                   Else           { "Enabled" -eq (Get-WindowsOptionalFeature -Online -FeatureName "IIS-WebServerRole").State }
  }
  Process {
    If (!$isInstalled) {
      If ($PSCmdlet.ShouldProcess("Install IIS")) {
        If ($isServer) {
          Install-WindowsFeature Web-Server -IncludeAllSubFeature -IncludeManagementTools
        } Else {
          @(
            "IIS-WebServerRole",          "IIS-WebServer",              "IIS-WebServerManagementTools",
            "IIS-ApplicationDevelopment", "IIS-ASPNET45",               "IIS-CommonHttpFeatures",
            "IIS-DefaultDocument",        "IIS-DirectoryBrowsing",      "IIS-HealthAndDiagnostics",
            "IIS-HttpCompressionStatic",  "IIS-HttpErrors",             "IIS-HttpLogging",
            "IIS-ISAPIExtensions",        "IIS-ISAPIFilter",            "IIS-NetFxExtensibility45",
            "IIS-Performance",            "IIS-RequestFiltering",       "IIS-Security",
            "IIS-StaticContent",          "NetFx4Extended-ASPNET45"
          ) | ForEach-Object {
            Enable-WindowsOptionalFeature -Online -FeatureName $_
          }
        }
      }
    }
    InstallRewriteModule
    InstallWebDeployModule
  }
}