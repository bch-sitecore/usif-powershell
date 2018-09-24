<#
  .SYNOPSIS
    Installs Java SE Development Kit v8, latest update.
#>
Function Install-JavaSE8 {
  [CmdletBinding(SupportsShouldProcess = $true)]
  Param()
  Begin {
    $url = GetJre8Url
    If (!$url) {
      Write-Error "Unable to get URL of JRE8"
    }

    $arch = ("x86","x64")[[System.Environment]::Is64BitOperatingSystem]
    $fileInfo = GetJre8FileInfo | Where-Object { $_.arch -eq $arch }
    $outFile = Join-Path $env:TEMP -ChildPath $fileInfo.filename
    $isInstalled = IsInstalled -Like "Java 8 Update *"
  }
  Process {
    If (!$isInstalled) {
      Write-Verbose "Installing Java SE 8"

      If (!(Test-Path $outFile) -and $PSCmdlet.ShouldProcess($outFile, "Download")) {
        Write-Verbose "Downloading $($outFile)"
        Invoke-RestMethod $Url -Method Post -Body @{ "$($fileInfo.cookiename)" = "on" } -SessionVariable "jre8Session" | Out-Null
        $cookie = New-Object System.Net.Cookie -Property @{
          Name = "oraclelicense"
          Value = "accept-securebackup-cookie"
          Domain = ".oracle.com"
        }
        $jre8Session.Cookies.Add($cookie)
        Invoke-WebRequest $fileInfo.filepath -OutFile $outFile -WebSession $jre8Session -UseBasicParsing
      }
      If ($PSCmdlet.ShouldProcess($outFile, "Install")) {
        $installArgs = @(
          "REBOOT=Disable"
          "STATIC=Enable"
          "WEB_JAVA=Disable"
          "WEB_ANALYTICS=Disable"
          "/s"
        )
        $result = Start-Process $outFile -ArgumentList $installArgs -Wait -PassThru
        If ($result.ExitCode -ne 0) {
          Write-Error "Non-zero exit code, $($result.ExitCode)"
        }

        $jreVersion = Get-ChildItem "HKLM:\SOFTWARE\JavaSoft\Java Runtime Environment" | Select-Object -ExpandProperty pschildname -Last 1
        Write-Verbose "JRE $($jreVersion)"
      }
      If (!(Test-path env:JAVA_HOME) -and $PSCmdlet.ShouldProcess("JAVA_HOME", "Set")) {
        $env:JAVA_HOME = Convert-Path (Join-Path $env:ProgramFiles -ChildPath "Java\jre*")
        [System.Environment]::SetEnvironmentVariable("JAVA_HOME", $env:JAVA_HOME, [System.EnvironmentVariableTarget]::Machine)
      }
      If ($PSCmdlet.ShouldProcess("PATH", "Update")) {
        AddPath (Join-Path $env:JAVA_HOME -ChildPath "bin")
      }
    } Else {
      Write-Verbose "Java SE 8 already installed"
    }
  }
}