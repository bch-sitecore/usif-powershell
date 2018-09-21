<#
  .SYNOPSIS
    Gets the greeting.
  .PARAMETER Name
    Name of the person to greet.
#>
Function Get-Greeting {
  [CmdletBinding()]
  Param(
    [Parameter(Position = 0, ValueFromPipeline = $true)]
    [string]$Name = "World"
  )
  Process {
    GetGreeting $Name
  }
}