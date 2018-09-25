<#
  .SYNOPSIS
    Installs Apache SOLR.
#>
Function Install-SOLR {
  [CmdletBinding(SupportsShouldProcess = $true)]
  Param()
  Begin {
    $version = "6.6.2"
    $url = "https://archive.apache.org/dist/lucene/solr/$($version)/solr-$($version).zip"
    $outFile = Join-Path $env:TEMP -ChildPath "solr-$($version).zip"
    $installPathPattern = Join-Path $env:ProgramData -ChildPath "solr-*"
    $isInstalled = $null -ne (Get-Command "solr" -ErrorAction SilentlyContinue)
  }
  Process {
    If (!$isInstalled) {
      Write-Verbose "Installing SOLR"

      ExpandArchive $url -OutFile $outFile -DestinationPath $env:ProgramData

      If ($PSCmdlet.ShouldProcess("`$env:PATH", "Update")) {
        $installPath = Convert-Path $installPathPattern
        $solrBin = Join-Path $installPath -ChildPath "bin"
        Write-Verbose "Adding '$($solrBin)' to `$env:PATH"
        AddPath $solrBin
      }
    } Else {
      Write-Verbose "SOLR already installed"
    }

    NewSolrConfig $installPath
    NewSolrService $installPath
  }
}