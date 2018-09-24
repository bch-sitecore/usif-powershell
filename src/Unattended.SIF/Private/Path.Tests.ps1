. "$($PSScriptRoot)\Path.ps1"

Describe "Path" -Tag "Private", "Path", "PowerShell $($PSVersionTable.PSVersion)" {
  $originalPath = [string]::Empty
  $absentPath = "TestDrive:\Foo"
  $presentPath = "TestDrive:\Bar"
  $PathSeparator = [System.IO.Path]::PathSeparator

  BeforeEach {
    $originalPath = $env:Path = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)

    $env:Path = @($env:Path, $presentPath) -join $PathSeparator
    [System.Environment]::SetEnvironmentVariable("Path", $env:Path, [System.EnvironmentVariableTarget]::Machine)
  }
  AfterEach {
    $env:Path = $originalPath
    [System.Environment]::SetEnvironmentVariable("Path", $env:Path, [System.EnvironmentVariableTarget]::Machine)
  }

  Context "AddPath" {
    It "Should add <Path>" -TestCases @(
      @{ Path = $absentPath }
    ) {
      Param($Path)

      ($env:Path -split $PathSeparator) | Should -Not -Contain $Path
      AddPath $Path
      ($env:Path -split $PathSeparator) | Should -Contain $Path
    }
  }
  Context "RemovePath" {
    It "Should remove <Path>" -TestCases @(
      @{ Path = $presentPath }
    ) {
      Param($Path)

      ($env:Path -split $PathSeparator) | Should -Contain $Path
      RemovePath $Path
      ($env:Path -split $PathSeparator) | Should -Not -Contain $Path
    }
  }
}