Function ExpandArchive {
  [CmdletBinding(SupportsShouldProcess = $true)]
  Param(
    [Parameter(Position = 0, Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Uri
    ,
    [Parameter(Position = 1, Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$OutFile
    ,
    [Parameter(Position = 2, Mandatory = $true)]
    [ValidateScript({ Test-Path $_ -PathType Container })]
    [string]$DestinationPath
  )
  Process {
    If (!(Test-Path $OutFile) -and $PSCmdlet.ShouldProcess($outFile, "Download")) {
      Invoke-WebRequest $Uri -OutFile $OutFile -UseBasicParsing
    }
    If ($PSCmdlet.ShouldProcess($DestinationPath, "Extract")) {
      Expand-Archive $OutFile -DestinationPath $DestinationPath -Force
    }
    If ($PSCmdlet.ShouldProcess($OutFile, "Remove")) {
      Remove-Item $OutFile
    }
  }
}
Function InstallMsi {
  [CmdletBinding(SupportsShouldProcess = $true)]
  Param(
    [Parameter(Position = 0, Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Url
    ,
    [Parameter(Position = 1, Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$OutFile
    ,
    [Parameter(Position = 2)]
    [AllowEmptyCollection()]
    [string[]]$ArgumentList = @("/quiet", "/norestart")
  )
  Process {
    If (!(Test-Path $OutFile) -and $PSCmdlet.ShouldProcess($OutFile, "Download")) {
      Write-Verbose "Downloading $($OutFile)"
      Invoke-WebRequest $Url -OutFile $OutFile -UseBasicParsing
    }
    If ($PSCmdlet.ShouldProcess($OutFile, "Install")) {
      Write-Verbose "Installing $($OutFile) ($($ArgumentList -join ' '))"
      $result = Start-Process "msiexec.exe" -ArgumentList (@("/i", $OutFile) + $ArgumentList) -Wait -PassThru
      If ($result.ExitCode -ne 0) {
        Write-Error "Non-zero exit code: $($result.ExitCode)"
      }
    }
    If ($PSCmdlet.ShouldProcess($OutFile, "Remove")) {
      Write-Verbose "Removing $($OutFile)"
      Remove-Item $OutFile
    }
  }
}