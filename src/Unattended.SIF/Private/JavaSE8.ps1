Function GetJdk8Url {
  Begin {
    $baseUrl = "https://www.oracle.com"
    $url = "$($baseUrl)/technetwork/java/javase/downloads/index.html"
  }
  Process {
    $jdk8 = (Invoke-WebRequest $url -UseBasicParsing).Content -split "[\r\n]" | Select-String "<a name=`"JDK8`""
    If ($jdk8 -match "href=`"([^`"]+)`"") {
      # e.g. https://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html
      "$($baseUrl)$($Matches[1])"
    }
  }
}
Function GetJre8Url {
  Begin {
    $baseUrl = "https://www.oracle.com"
    $url = "$($baseUrl)/technetwork/java/javase/downloads/index.html"
  }
  Process {
    $jdk8 = (Invoke-WebRequest $url -UseBasicParsing).Content -split "[\r\n]" | Select-String "/java/javase/downloads/jre8-"
    If ($jdk8 -match "href=`"([^`"]+)`"") {
      # e.g. https://www.oracle.com/technetwork/java/javase/downloads/jre8-downloads-2133155.html
      "$($baseUrl)$($Matches[1])"
    }
  }
}
Function GetJdk8FileInfo {
  Begin {
    $url = GetJdk8Url
    If (!$url) {
      Write-Error "Unable to get URL of JDK8"
    }

    $pattern = "downloads\['(?<cookieName>[^']+)'\]\['files'\]\['[^']+-windows-(?:x64|i586)\.exe'\] = (?<jso>\{.*?\})"
    $results = @()
  }
  Process {
    (Invoke-WebRequest $url -UseBasicParsing).Content -split "[\r\n]" | Select-String $pattern | ForEach-Object {
      If ($_ -match $pattern) {
        $result = $Matches.jso | ConvertFrom-Json
        $result | Add-Member NoteProperty "cookiename" $Matches.cookieName
        $result | Add-Member NoteProperty "arch" ("x86","x64")[$result.filepath -like "*-x64.exe"]
        $result | Add-Member NoteProperty "filename" (Split-Path $result.filepath -Leaf)
        $results += $result
      }
    }
  }
  End {
    <#
      e.g.
        title      : Windows x86
        size       : 194.41 MB
        filepath   : http://download.oracle.com/otn-pub/java/jdk/8u181-b13/96a7b8442fe848ef90c96a2fad6ed6d1/jdk-8u181-windows-i586.exe
        MD5        : f06f338d13a816c6062974a8586336d0
        SHA256     : 37b090d99104dab7aeae582dbad07731d5550aeb8ebd5eaf0b131e559dd2e30b
        cookiename : jdk-8u181-oth-JPR
        arch       : i586
        filename   : jdk-8u181-windows-i586.exe

        title      : Windows x64
        size       : 202.73 MB
        filepath   : http://download.oracle.com/otn-pub/java/jdk/8u181-b13/96a7b8442fe848ef90c96a2fad6ed6d1/jdk-8u181-windows-x64.exe
        MD5        : b69f3ed37adbfec1f724bd5e9a9a4065
        SHA256     : 6d1e254081d56fa460505d5b0f10ce1e33426c44dfbcab838c2be620f35997a4
        cookiename : jdk-8u181-oth-JPR
        arch       : x64
        filename   : jdk-8u181-windows-x64.exe
    #>
    $results
  }
}
Function GetJre8FileInfo {
  Begin {
    $url = GetJre8Url
    If (!$url) {
      Write-Error "Unable to get URL of JRE8"
    }

    $pattern = "downloads\['(?<cookieName>[^']+)'\]\['files'\]\['[^']+-windows-(?:x64|i586)\.exe'\] = (?<jso>\{.*?\})"
    $results = @()
  }
  Process {
    (Invoke-WebRequest $url -UseBasicParsing).Content -split "[\r\n]" | Select-String $pattern | ForEach-Object {
      If ($_ -match $pattern) {
        $result = $Matches.jso | ConvertFrom-Json
        $result | Add-Member NoteProperty "cookiename" $Matches.cookieName
        $result | Add-Member NoteProperty "arch" ("x86","x64")[$result.filepath -like "*-x64.exe"]
        $result | Add-Member NoteProperty "filename" (Split-Path $result.filepath -Leaf)
        $results += $result
      }
    }
  }
  End {
    <#
      e.g.
        title      : Windows x86 Offline
        size       : 61.55 MB
        filepath   : http://download.oracle.com/otn-pub/java/jdk/8u181-b13/96a7b8442fe848ef90c96a2fad6ed6d1/jre-8u181-windows-i586.exe
        MD5        : b97be9584268202f2fba665505f7828e
        SHA256     : 9e5e6a1c5d26d93454751e65486f728233fdac3b50ff763f6709fb87dd960ce5
        cookiename : jre-8u181-oth-JPR
        arch       : x86
        filename   : jre-8u181-windows-i586.exe

        title      : Windows x64
        size       : 68.47 MB
        filepath   : http://download.oracle.com/otn-pub/java/jdk/8u181-b13/96a7b8442fe848ef90c96a2fad6ed6d1/jre-8u181-windows-x64.exe
        MD5        : 7f125bd071f2f83d91a8146bcb48bda5
        SHA256     : cd2f756133d59525869acb605a54efd132fcd7eaf53e2ec040d92ef40a2ea60a
        cookiename : jre-8u181-oth-JPR
        arch       : x64
        filename   : jre-8u181-windows-x64.exe
    #>
    $results
  }
}