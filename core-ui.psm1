function Display-Hosts {
    Write-Host ""
    Write-Host "****************************************"    
    Write-Host "Selected Hosts:"
    Get-Hosts | Write-Host
    Write-Host "****************************************"
}

function Display-Tasks {
    param([Parameter(ValueFromPipeline=$true)]$SelectedTasks)
    Write-Host ""
    Write-Host "****************************************"    
    Write-Host -NoNewline "Available Tasks: "
    (Get-TaskNames | Sort-Object) -join ", " | Write-Host
    Write-Host "****************************************"    
    Write-Host -NoNewline "Selected Tasks: "
    $SelectedTasks -join ", " | Write-Host
    Write-Host "****************************************"
}

function Write-Header {
    param(
        [Parameter(ValueFromPipeline=$true)]$SelectedTasks,
        $ImpersonatedUser
    )
    Display-Hosts
    Display-Tasks -SelectedTasks $SelectedTasks

    if ($ImpersonatedUser -ne $null) {
        Write-Host ""
        Write-Host "Impersonated user: $ImpersonatedUser"
    }
}

function Write-Menu {
Write-Host ""
    Write-Host "Options:"
    Write-Host "0) Quit (q, quit, exit)"
    Write-Host "1) Add host"
    Write-Host "2) Remove host"
    Write-Host "3) Add task"
    Write-Host "4) Remove task"
    Write-Host "5) Set tasks"
    Write-Host "6) Impersonate User"
    Write-Host "7) Stop impersonating user"
    write-host "8) Execute tasks on hosts (exe*, run)"
    Write-Host "9) Run raw command (raw)"
    Write-Host ""
}
