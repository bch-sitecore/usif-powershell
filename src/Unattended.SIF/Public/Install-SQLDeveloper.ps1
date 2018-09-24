<#
  .SYNOPSIS
    Installs SQL Server 2017 Developer
#>
Function Install-SQLDeveloper {
  [CmdletBinding(SupportsShouldProcess = $true)]
  Param()
  Begin {
    $boxOutFile = Join-Path $env:TEMP -ChildPath "SQLServer2017-DEV-x64-ENU.box"
    $boxUrl = "https://go.microsoft.com/fwlink/?linkid=840944"
    $exeOutFile = Join-Path $env:TEMP -ChildPath "SQLServer2017-DEV-x64-ENU.exe"
    $exeUrl = "https://go.microsoft.com/fwlink/?linkid=840945"
    $setupPath = Join-Path $env:TEMP -ChildPath "sqlsetup"
    $setupExe = Join-Path $setupPath -ChildPath "setup.exe"

    $isInstalled = IsInstalled -Like "Microsoft SQL Server *"
  }
  Process {
    If (!$isInstalled) {
      Write-Verbose "Installing SQL Server Developer"
      
      If (!(Test-Path $boxOutFile) -and $PSCmdlet.ShouldProcess($boxOutFile, "Download")) {
        Write-Verbose "Downloading $($boxOutFile)"
        Invoke-WebRequest $boxUrl -OutFile $boxOutFile -UseBasicParsing
      }
      If (!(Test-Path $exeOutFile) -and $PSCmdlet.ShouldProcess($exeOutFile, "Download")) {
        Write-Verbose "Downloading $($exeOutFile)"
        Invoke-WebRequest $exeUrl -OutFile $exeOutFile -UseBasicParsing
      }
      If (!(Test-Path $setupPath) -and $PSCmdlet.ShouldProcess($setupPath, "Extract")) {
        Write-Verbose "Extracting $($exeOutFile) to $($setupPath)"
        $result = Start-Process $exeOutFile -ArgumentList "/qs", "/x:$($setupPath)" -Wait -PassThru
        If ($result.ExitCode -ne 0) {
          Write-Error "Non-zero exit code: $($result.ExitCode)"
        }
      }
      If ($PSCmdlet.ShouldProcess($boxOutFile, "Remove")) {
        Write-Verbose "Removing $($boxOutFile)"
        Remove-Item $boxOutFile
      }
      If ($PSCmdlet.ShouldProcess($exeOutFile, "Remove")) {
        Write-Verbose "Removing $($exeOutFile)"
        Remove-Item $exeOutFile
      }
      If ($PSCmdlet.ShouldProcess($setupExe, "Install")) {
        Write-Verbose "Running installer $($setupExe)"
        & $setupExe /q /ACTION=Install `
          /INSTANCENAME=MSSQLSERVER `
          /FEATURES=SQLEngine `
          /UPDATEENABLED=0 `
          /SQLSVCACCOUNT='NT AUTHORITY\System' `
          /SQLSYSADMINACCOUNTS='BUILTIN\ADMINISTRATORS' `
          /TCPENABLED=1 `
          /NPENABLED=0 `
          /IACCEPTSQLSERVERLICENSETERMS
      }
      If ($PSCmdlet.ShouldProcess($setupPath, "Remove")) {
        Write-Verbose "Removing $($setupPath)"
        Remove-Item $setupPath -Recurse
      }
    } Else {
      Write-Verbose "SQL Server Developer already installed"
    }
    If ($PSCmdlet.ShouldProcess("MSSQLSERVER", "Configure")) {
      Write-Verbose "Configuring SQL Server Developer"

      Write-Verbose "Stopping MSSQLSERVER service"
      Stop-Service "MSSQLSERVER"

      Write-Verbose "Modifying registry"
      $keyRoot = (Convert-Path "HKLM:\Software\Microsoft\Microsoft SQL Server\MSSQL*.MSSQLSERVER\MSSQLServer") -replace "HKEY_LOCAL_MACHINE", "HKLM:"
      @(
        @{
            Path = "$($keyRoot)\SuperSocketNetLib\TCP\IPAll"
            Name = "TCPDynamicPorts"
            Value = ""
        },
        @{
            Path = "$($keyRoot)\SuperSocketNetLib\TCP\IPAll"
            Name = "TCPPort"
            Value = 1433
        },
        @{
            Path = $keyRoot
            Name = "LoginMode"
            Value = 2
        }
      ) | ForEach-Object {
        $reg = $_

        Write-Verbose "[$($reg.Path)]`n$($reg.Name)=$($reg.Value)"
        Set-ItemProperty $reg.Path -Name $reg.Name -Value $reg.Value
      }
    
      Write-Verbose "Starting MSSQLSERVER service"
      Start-Service "MSSQLSERVER"
    }
  }
}