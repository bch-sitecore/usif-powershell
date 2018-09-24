Function InstallMsi {
  [CmdletBinding(SupportsShouldProcess = $true)]
  Param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateNotNullOrEmpty()]
    [string]$Url
    ,
    [Parameter(Mandatory = $true, Position = 1)]
    [ValidateNotNullOrEmpty()]
    [string]$OutFile
    ,
    [Parameter(Position = 2)]
    [AllowEmptyCollection()]
    [string[]]$ArgumentList = @("/quiet", "/norestart")
  )
  Process {
    If (!(Test-Path $OutFile) -and $PSCmdlet.ShouldProcess($OutFile, "Download")) {
      Invoke-WebRequest $Url -OutFile $OutFile -UseBasicParsing
    }
    If ($PSCmdlet.ShouldProcess($OutFile, "Install")) {
      $result = Start-Process "msiexec.exe" -ArgumentList (@("/i", $OutFile) + $ArgumentList) -Wait -PassThru
      If ($result.ExitCode -ne 0) {
        Write-Error "Non-zero exit code: $($result.ExitCode)"
      }
    }
    If ($PSCmdlet.ShouldProcess($OutFile, "Remove")) {
      Remove-Item $OutFile
    }
  }
}