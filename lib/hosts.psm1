$script:hosts = @( )

function Load-Hosts {
    param([Parameter(Mandatory=$true)]$File)
    $contents = Get-Content -Path $File
    $script:hosts = $contents -split [System.Environment]::NewLine
}

function Save-Hosts {
    param([Parameter(Mandatory=$true)]$File)
    Set-Content -Path $File -Value ($script:hosts -join [System.Environment]::NewLine)
}

function Get-Hosts {
    return $script:hosts
}

function Add-Host { 
    param([Parameter(Mandatory=$true)]$HostName)
    $script:hosts += $HostName
    $script:hosts = $script:hosts | sort
}

function Remove-Host {
    param([Parameter(Mandatory=$true)]$HostName)
    $script:hosts = $script:hosts -ne $HostName
}

function Set-Hosts {
    param([Parameter(Mandatory=$true)]$Hosts)
    $script:hosts = $Hosts
}

Export-ModuleMember *-*