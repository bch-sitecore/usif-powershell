$psVersion = $PSVersionTable.PSVersion

Describe "Get-Greeting" -Tag "Unattended.SIF", "Public" {
  Context "PowerShell ${psVersion}" {
    It "Should return default greeting" {
      Get-Greeting | Should -Be "Hello, World!"
    }
    It "Should return greeting for <Name>" -TestCases @(
      @{ Name = "Joe" }, @{ Name = "Sue" }
    ) {
      Param([string]$Name)

      Get-Greeting -Name $Name | Should -Be "Hello, ${Name}!"
    }
  }
}