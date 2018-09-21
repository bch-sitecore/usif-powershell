Function GetGreeting {
  Param(
    [Parameter(Position = 0, ValueFromPipeline = $true)]
    [string]$Name = "World"
  )
  Process {
    "Hello, {0}!" -f $Name
  }
}