$psVersion = $PSVersionTable.PSVersion

Describe "Invoke-SystemCheck" -Tag "Unattended.SIF", "Public" {
  Context "PowerShell ${psVersion}" {
    It -Skip "Should return Pass" {
      $check = Invoke-SystemCheck
      $check | ConvertTo-Json | Out-Host
      $check.Status | Should -Be "Pass"
    }
  }
}