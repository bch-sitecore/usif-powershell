<#
  .SYNOPSIS
    Tests if an application is installed.
  .PARAMETER Exact
    Tests for an exact naming match.
  .PARAMETER Like
    Tests for a likeness naming match.
  .PARAMETER Architecture
    Targets a specific architecture.
#>
Function IsInstalled
{
  [CmdletBinding(DefaultParameterSetName = "Exact")]
  Param(
    [Parameter(ParameterSetName = "Exact", Mandatory = $true, Position = 0)]
    [ValidateNotNullOrEmpty()]
    [Alias("EQ")]
    [string]$Exact,

    [Parameter(ParameterSetName = "Like", Mandatory = $true, Position = 0)]
    [ValidateNotNullOrEmpty()]
    [string]$Like
    ,
    [Parameter(ParameterSetName = "Exact", Position = 1)]
    [Parameter(ParameterSetName = "Like", Position = 1)]
    [ValidateSet("Any", "x86", "x64")]
    [Alias("Arch")]
    [string]$Architecture = "Any"
  )
  Begin {
    $Path = @("HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*")
    if ([Environment]::Is64BitOperatingSystem) {
      $Path += "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    }
  }
  Process {
    $null -ne (Get-ItemProperty $path | Where-Object { $_.DisplayName -and $_.UninstallString } | Where-Object {
      If ($PSCmdlet.ParameterSetName -eq "Exact") {
        $_.DisplayName -eq $Exact
      } Else {
        $_.DisplayName -like $Like
      }
    } | Select-Object DisplayName, @{
      Name = "Architecture"
      Expression = { ("x86","x64")[$_.PSParentPath -notlike "*\Wow6432Node\*"] }
    } | Where-Object { ($Architecture -eq "Any") -or ($_.Architecture -eq $Architecture) })
  }
}