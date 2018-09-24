[CmdletBinding()]
Param()
$ErrorActionPreference = "Stop"

$moduleName = "Unattended.SIF"
$modulePath = Convert-Path $PSScriptRoot\src\$moduleName

If (Test-Path env:APPVEYOR) {
  $testResults = Invoke-Pester $modulePath -OutputFile .\TestResults.xml -OutputFormat NUnitXml -PassThru
  (New-Object "System.Net.WebClient").UploadFile("https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)", (Resolve-Path .\TestResults.xml))
  Remove-Item .\TestResults.xml
  If ($testResults.FailedCount -gt 0) {
    Write-Error "$($testResults.FailedCount) tests failed."
  }
} Else {
  Invoke-Pester $modulePath
}

Remove-Module $moduleName -Force -ErrorAction SilentlyContinue
Import-Module $modulePath -Scope Local

If (Test-Path env:APPVEYOR) {
  $testResults = Invoke-Pester .\test -OutputFile .\TestResults.xml -OutputFormat NUnitXml -PassThru
  (New-Object "System.Net.WebClient").UploadFile("https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)", (Resolve-Path .\TestResults.xml))
  Remove-Item .\TestResults.xml
  If ($testResults.FailedCount -gt 0) {
    Write-Error "$($testResults.FailedCount) tests failed."
  }
} Else {
  Invoke-Pester .\test
}

Write-Host "Test complete."