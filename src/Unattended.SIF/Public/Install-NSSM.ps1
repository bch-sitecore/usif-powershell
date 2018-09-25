<#
  .SYNOPSIS
    Installs the Non-Sucking Service Manager
#>
Function Install-NSSM {
  [CmdletBinding(SupportsShouldProcess = $true)]
  Param()
  Begin {
    $version = "2.24"
    $url = "https://nssm.cc/release/nssm-$($version).zip"
    $outFile = Join-Path $env:TEMP -ChildPath "nssm-$($version).zip"
    $installPathPattern = Join-Path $env:ProgramData -ChildPath "nssm-*"
    $isInstalled = $null -ne (Get-Command "nssm" -ErrorAction SilentlyContinue)
  }
  Process {
    If (!($isInstalled)) {
      Write-Verbose "Installing NSSM"

      ExpandArchive $url -OutFile $outFile -DestinationPath $env:ProgramData

      If ($PSCmdlet.ShouldProcess("`$env:PATH", "Update")) {
        $installPath = Convert-Path $installPathPattern
        $nssmBin = Join-Path $installPath -ChildPath ("win32","win64")[[Environment]::Is64BitOperatingSystem]
        Write-Verbose "Adding '$($nssmBin)' to `$env:PATH"
        AddPath $nssmBin
      }
    } Else {
      Write-Verbose "NSSM alrady installed"
    }
  }
}