. "$($PSScriptRoot)\Cert.ps1"

Describe "Path" -Tag "Private", "Path", "PowerShell $($PSVersionTable.PSVersion)" {
  $certLocation = "Cert:\LocalMachine\My"
  $certDnsName = "unattended.sif.local"
  $certFriendlyName = "Unattended.SIF"
  $cert = $null

  BeforeEach {
    $cert = New-SelfSignedCertificate -CertStoreLocation Cert:\LocalMachine\My `
        -FriendlyName $certFriendlyName -DnsName $certDnsName -NotAfter (Get-Date).AddMinutes(5)
  }
  AfterEach {
    Remove-Item Cert:\LocalMachine\My\$($cert.Thumbprint)
  }

  Context "GetCert" {
    It "Should find certificate by DnsName <DnsName>" -TestCases @(
      @{ DnsName = $certDnsName; Location = $certLocation }
    ) {
      Param($DnsName)

      $match = GetCert -ByDnsName $DnsName
      $match | Should -Not -Be $null
    }
    It "Should find certificate by FriendlyName <FriendlyName>" -TestCases @(
      @{ FriendlyName = $certFriendlyName; Location = $certLocation },
      @{ FriendlyName = "Microsoft Root Authority"; Location = "Cert:\LocalMachine\Root" }
    ) {
      Param($FriendlyName,$Location)

      $match = GetCert -ByFriendlyName $FriendlyName -In $Location
      $match | Should -Not -Be $null
    }
    It "Should find certificate by Thumbprint <Thumbprint>" -TestCases @(
      @{ Thumbprint = "a43489159a520f0d93d032ccaf37e7fe20a8b419"; Location = "Cert:\LocalMachine\Root" } # Microsoft Root Authority
    ) {
      Param($Thumbprint,$Location)

      $match = GetCert -ByThumbprint $Thumbprint -In $Location
      $match | Should -Not -Be $null
    }
  }
}