Function GetSolrHost {
  [CmdletBinding()]
  Param(
    [Parameter(Position = 0, Mandatory = $true)]
    [ValidateScript({ Test-Path $_ -PathType Container })]
    [ValidateScript({ Test-Path (Join-Path $_ -ChildPath "bin\solr.in.cmd") })]
    [string]$Path
    ,
    [Parameter(Position = 1)]
    [ValidateNotNullOrEmpty()]
    [string]$DefaultHost = "solr.local"
  )
  Begin {
    $cmdFile = Join-Path $Path -ChildPath "bin\solr.in.cmd"
    $result = $DefaultHost
  }
  Process {
    If (Test-Path $cmdFile) {
      $match = (Get-Content $cmdFile) | Select-String "^set SOLR_HOST=\w+"
      If ($match) {
        $result = $match -replace "set SOLR_HOST="
      }
    }
    $result
  }
}
Function GetSolrPort {
  [CmdletBinding()]
  Param(
    [Parameter(Position = 0, Mandatory = $true)]
    [ValidateScript({ Test-Path $_ -PathType Container })]
    [ValidateScript({ Test-Path (Join-Path $_ -ChildPath "bin\solr.in.cmd") })]
    [string]$Path
    ,
    [Parameter(Position = 1)]
    [ValidateRange(1, 65535)]
    [int]$DefaultPort = 8983
  )
  Begin {
    $cmdFile = Join-Path $Path -ChildPath "bin\solr.in.cmd"
    $result = $DefaultPort
  }
  Process {
    If (Test-Path $cmdFile) {
      $match = (Get-Content $cmdFile) | Select-String "^set SOLR_PORT=\d+"
      If ($match) {
        $result = [int]($match -replace "set SOLR_PORT=")
      }
    }
    $result
  }
}
Function NewSolrConfig {
  [CmdletBinding(SupportsShouldProcess = $true)]
  Param(
    [Parameter(Position = 0, Mandatory = $true)]
    [ValidateScript({ Test-Path $_ -PathType Container })]
    [ValidateScript({ Test-Path (Join-Path $_ -ChildPath "bin\solr.in.cmd") })]
    [string]$Path
    ,
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$Hostname = "solr.local"
    ,
    [Parameter()]
    [ValidateRange(1, 65535)]
    [int]$Port = 8983
  )
  Begin {
    $binPath = Join-Path $Path -ChildPath "bin"
    $serverPath = Join-Path $Path -ChildPath "server"
    $friendlyName = "Apache Solr"

    $cmdFile = Join-Path $binPath -ChildPath "solr.in.cmd"
    $cmdFileOrig = Join-Path $binPath -ChildPath "solr.in.cmd.orig"

    $certFile = Join-Path $serverPath -ChildPath "etc\solr-ssl.keystore.pfx"
    $certPassword = NewRandomPassword -Length 12
  }
  Process {
    If ((Test-Path $certFile) -and $PSCmdlet.ShouldProcess($certFile, "Remove")) {
      Write-Verbose "Removing '$(certFile)'"
      Remove-Item $certFile
    }
    If ($PSCmdlet.ShouldProcess($certFile, "Create")) {
      Write-Verbose "Creating SOLR cert '$($certFile)'"
      $cert = GetCert -ByFriendlyName $friendlyName -CertStoreLocation "Cert:\LocalMachine\Root"
      If (!$cert) {
        $cert = GetCert -ByFriendlyName $friendlyName -CertStoreLocation "Cert:\LocalMachine\My"
        If (!$cert) {
          $cert = New-SelfSignedCertificate -CertStoreLocation "Cert:\LocalMachine\My" `
            -DnsName $Hostname -FriendlyName $friendlyName -NotAfter (Get-Date).AddYears(2)
          Write-Verbose "  created w/ Thumbprint $($cert.Thumbprint)"
        } Else {
          Write-Verbose "  found w/ Thumbprint $($cert.Thumbprint)"
        }

        $storeName = [System.Security.Cryptography.X509Certificates.StoreName]::Root
        $storeLocation = [System.Security.Cryptography.X509Certificates.StoreLocation]::LocalMachine
        $openFlags = [System.Security.Cryptography.X509Certificates.OpenFlags]::MaxAllowed
        $store = New-Object System.Security.Cryptography.X509Certificates.X509Store $storeName, $storeLocation
        $store.Open($openFlags)
        $store.Add($cert)
        $store.Close()
        Write-Verbose "  added to Cert:\LocalMachine\Root"
      } Else {
        Write-Verbose "  exists w/ Thumbprint $($cert.Thumbprint)"
      }

      Write-Verbose "Exporting certificate to '$($certFile)' w/ password $($certPassword)"
      Export-PfxCertificate -Cert $cert -FilePath $certFile `
        -Password (ConvertTo-SecureString $certPassword -AsPlainText -Force) | Out-Null
    }
    If (!(Test-Path $cmdFileOrig) -and $PSCmdlet.ShouldProcess($cmdFile, "Backup")) {
      Write-Verbose "Backing up $($cmdFile) to $($cmdFileOrig)"
      Move-Item $cmdFile -Destination $cmdFileOrig
    }
    If ($PSCmdlet.ShouldProcess($cmdFile, "Write")) {
      Write-Verbose "Writing config to $($solrInCmd)"
      $config = @(
        "REM",
        "REM Generated on $(Get-Date -Format G) by Unattended.SIF",
        "REM",
        "set SOLR_HOST=$($Hostname)",
        "set SOLR_PORT=$($Port)",
        "set SOLR_SSL_KEY_STORE=etc/$(Split-Path $certFile -Leaf)",
        "set SOLR_SSL_KEY_STORE_PASSWORD=$($certPassword)",
        "set SOLR_SSL_KEY_STORE_TYPE=PKCS12",
        "set SOLR_SSL_TRUST_STORE=etc/$(Split-Path $certFile -Leaf)",
        "set SOLR_SSL_TRUST_STORE_PASSWORD=$($certPassword)",
        "set SOLR_SSL_TRUST_STORE_TYPE=PKCS12",
        "set SOLR_OPTS=%SOLR_OPTS% -Dsolr.log.muteconsole"
      )
      $config | ForEach-Object -Begin { $line = 0 } { $line++; "{0}: {1}" -f ([string]$line).PadLeft(3), $_ } | Write-Verbose
      $config | Set-Content $cmdFile
    }
    If (($Hostname -ne "localhost" -and $Hostname -ne $env:COMPUTERNAME) -and $PSCmdlet.ShouldProcess("HOSTS", "Update")) {
      Write-Verbose "Adding $($Hostname) to HOSTS file"
      AddHostsEntry $Hostname "127.0.0.1"
    }
  }
}
Function NewSolrService {
  [CmdletBinding(SupportsShouldProcess = $true)]
  Param(
    [Parameter(Position = 0, Mandatory = $true)]
    [ValidateScript({ Test-Path $_ -PathType Container })]
    [ValidateScript({ Test-Path (Join-Path $_ -ChildPath "bin\solr.in.cmd") })]
    [string]$Path
  )
  Begin {
    $binPath = Join-Path $Path -ChildPath "bin"
    $serverPath = Join-Path $Path -ChildPath "server"
    $serviceName = "Apache Solr 6.6.2"
    $serviceHost = GetSolrHost $Path
    $servicePort = GetSolrPort $Path
    $logsPath = Join-Path $Path -ChildPath "server\logs"

    $nssm = (Get-Command "nssm.exe" -ErrorAction SilentlyContinue).Source
    If (!$nssm) {
      Write-Error "NSSM must be installed and discoverable via `$env:PATH (run Install-NSSM first)"
    }

    $isInstalled = $null -ne (Get-Service $serviceName -ErrorAction SilentlyContinue)
  }
  Process {
    If (!$isInstalled) {
      Write-Host "Installing Solr Service"
      If ($PSCmdlet.ShouldProcess($serviceName, "Install service")) {

        $serviceCmd = "`"`"$(Join-Path $binPath -ChildPath 'solr.cmd')`"`" start -port $($servicePort) -foreground -verbose"

        & $nssm install $serviceName "cmd.exe" "/C $($serviceCmd) < nul" | Out-Null
        & $nssm set $serviceName Description "Apache Solr 6.6.2 (https://$($solrHost):$($solrPort)/solr/#)"
        & $nssm set $serviceName AppStdoutCreationDisposition 2
        & $nssm set $serviceName AppStdout (Join-Path $logsPath -ChildPath "nssm.log")
        & $nssm set $serviceName AppStderrCreationDisposition 2
        & $nssm set $serviceName AppStderr (Join-Path $logsPath -ChildPath "nssm.log")
        & $nssm set $serviceName AppRotateFiles 1
        & $nssm set $serviceName AppRotateBytes 1048576
        & $nssm set $serviceName Start SERVICE_AUTO_START
      }
    } Else {
      Write-Verbose "Solr Service already installed"
    }
  }
}