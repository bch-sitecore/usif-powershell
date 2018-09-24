Function InstallRewriteModule {
  [CmdletBinding(SupportsShouldProcess = $true)]
  Param()
  Begin {
    $url32 = "http://download.microsoft.com/download/6/8/F/68F82751-0644-49CD-934C-B52DF91765D1/rewrite_x86_en-US.msi"
    $url64 = "http://download.microsoft.com/download/D/D/E/DDE57C26-C62C-4C59-A1BB-31D58B36ADA2/rewrite_amd64_en-US.msi"
    
    $url = ($url32, $url64)[[System.Environment]::Is64BitOperatingSystem]
    $outFile = Join-Path $env:TEMP -ChildPath "rewrite_en-US.msi"
    $isInstalled = IsInstalled -Like "IIS URL Rewrite Module *"
  }
  Process {
    If (!$isInstalled) {
      InstallMsi $url -OutFile $outFile
    }
  }
}
Function InstallWebDeployModule {
  [CmdletBinding(SupportsShouldProcess = $true)]
  Param()
  Begin {
    $url32 = "http://download.microsoft.com/download/0/1/D/01DC28EA-638C-4A22-A57B-4CEF97755C6C/WebDeploy_x86_en-US.msi"
    $url64 = "http://download.microsoft.com/download/0/1/D/01DC28EA-638C-4A22-A57B-4CEF97755C6C/WebDeploy_amd64_en-US.msi"
    
    $url = ($url32, $url64)[[System.Environment]::Is64BitOperatingSystem]
    $outFile = Join-Path $env:TEMP -ChildPath "WebDeploy_en-US.msi"
    $isInstalled = IsInstalled -Like "IIS URL Rewrite Module *"
  }
  Process {
    If (!$isInstalled) {
      InstallMsi $url -OutFile $outFile
    }
  }
}