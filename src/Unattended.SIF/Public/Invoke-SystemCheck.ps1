<#
  .SYNOPSIS
    Performs a system check validating if Sitecore is eligble to be installed.
#>
Function Invoke-SystemCheck {
  Begin {
    $result = [PSObject]@{
      Status = "Inconclusive"
      Checks = @()
    }
  }
  Process {
    $result.Checks += CheckCpu
    $result.Checks += CheckMemory
    $result.Checks += CheckOS
    $result.Checks += CheckNetFramework
  }
  End {
    $result.Status = ("Fail", "Pass")[$null -ne ($result.Checks | Where-Object { $_.Mandatory -and $_.Status -ne "Pass" })]

    $result
  }
}

Function CheckCpu {
  Begin {
    $check = [PSObject]@{
      Name = "CPU Core Count"
      Details = [string]::Empty
      Mandatory = $true
      Expects = "4+ core processor"
      Status = "Inconclusive"
    }

    $cpu = Get-WmiObject Win32_processor | Select-Object Name, DeviceID, NumberOfCores, NumberOfLogicalProcessors, Addresswidth
  }
  Process {
    $check.Details = "found {0}" -f $cpu.Name
    $check.Status = ("Fail", "Pass")[$cpu.NumberOfCores -ge 4]
  }
  End {
    $check
  }
}
Function CheckMemory {
  Begin {
    $check = [PSObject]@{
      Name = "Random Access Memory (RAM)"
      Details = [string]::Empty
      Mandatory = $true
      Expects = "16GB+ of RAM"
      Status = "Inconclusive"
    }

    $ram = (Get-CimInstance Win32_PhysicalMemory | Measure-Object Capacity -Sum | Select-Object -ExpandProperty Sum) / 1GB
  }
  Process {
    $check.Details = "{0}GB of RAM" -f $ram
    $check.Status = ("Fail", "Pass")[$ram -ge 16]
  }
  End {
    $check
  }
}
Function CheckNetFramework {
  Begin {
    $check = [PSObject]@{
      Name = ".NET Framework"
      Details = [string]::Empty
      Mandatory = $true
      Expects = ".NET Framework 4.6.2 or later"
      Status = "Inconclusive"
    }

    # https://docs.microsoft.com/en-us/dotnet/framework/migration-guide/how-to-determine-which-versions-are-installed
    $invalidReleases = @(
      @{ Release = "378389"; Version = "4.5"; Target = "*" }
      @{ Release = "378675"; Version = "4.5.1"; Target = "Windows 8.1 or Windows Server 2012 R2" }
      @{ Release = "378758"; Version = "4.5.1"; Target = "Windows 8, Windows 7 SP1, or Windows Vista SP2" }
      @{ Release = "379893"; Version = "4.5.2"; Target = "*" }
      @{ Release = "393295"; Version = "4.6"; Target = "Windows 10" }
      @{ Release = "393297"; Version = "4.6"; Target = "non-Windows 10" }
      @{ Release = "394254"; Version = "4.6.1"; Target = "Windows 10" }
      @{ Release = "394271"; Version = "4.6.1"; Target = "non-Windows 10" }
    )
    $validReleases = @(
      @{ Release = "394802"; Version = "4.6.2"; Target = "Windows 10" }
      @{ Release = "394806"; Version = "4.6.2"; Target = "non-Windows 10" }
      @{ Release = "460798"; Version = "4.7"; Target = "Windows 10" }
      @{ Release = "460805"; Version = "4.7"; Target = "non-Windows 10" }
      @{ Release = "461308"; Version = "4.7.1"; Target = "Windows 10" }
      @{ Release = "461310"; Version = "4.7.1"; Target = "non-Windows 10" }
      @{ Release = "461808"; Version = "4.7.2"; Target = "Windows 10" }
      @{ Release = "461814"; Version = "4.7.2"; Target = "non-Windows 10" }
    )
  }
  Process {
    Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full" -ErrorAction SilentlyContinue | ForEach-Object {
      $release = $_.Release
      $valid = $validReleases | Where-Object { $_.Release -eq $release }
      If ($valid) {
        $check.Status = "Pass"
        $check.Details = "found .NET Framework v{0} (Targetting {1})" -f $valid.Version, $valid.Target
      } Else {
        $invalid = $invalidReleases | Where-Object { $_.Release -eq $release }
        If ($invalid) {
          $check.Status = "Fail"
          $check.Status = "found .NET Framework v{0} (Targetting {1})" -f $invalid.Version, $invalid.Target
        }
      }
    }
  }
  End {
    $check
  }
}
Function CheckOS {
  Begin {
    $check = [PSObject]@{
      Name = "Operating System"
      Details = [string]::Empty
      Mandatory = $true
      Expects = "Windows Server 2016, Windows Server 2012 R2, Windows 10 (x64/x32), Windows 8.1 (x64/x32)"
      Status = "Inconclusive"
    }

    $os = Get-CimInstance Win32_OperatingSystem | Select-Object Caption, OSArchitecture, Version
    #TODO Make version table and also compare arch
  }
  Process {
    $check.Details = "found {0} ({1})" -f $os.Caption, $os.OSArchitecture
    If (
      ($os.Version -ge [version]"6.3" -and $os.Version -lt [version]"6.4") -or
      ($os.Version -ge [version]"10.0" -and $os.Version -lt [version]"10.1")
    ) {
      $check.Status = "Pass"
    } Else {
      $check.Status = "Fail"
    }
  }
  End {
    $check
  }
}