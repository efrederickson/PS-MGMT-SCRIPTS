# Automatically process tasks to run

Import-Module -DisableNameChecking -Force $PSScriptRoot\core.psm1
Import-Module -Force $PSScriptRoot\lib\common.psm1
Expand-RelativeLibPaths hosts RemoteDispatch tasks threading Write-Colors | % { Import-Module -DisableNameChecking -Force $_ }

Load-Tasks -Directory $PSScriptRoot\tasks
Load-Hosts -File $PSScriptRoot\hosts

# set tasks & verify tasks
$script:selectedTasks = @( )

$args | % {
    if ((Get-TaskNames).contains($_)) {
        Write-Green "Adding task $_"
        $script:selectedTasks += $_
    } else {
        Write-Red "Task $_ does not exist"
        exit 1
    }
}

Execute-SelectedTasks -SelectedTasks $script:selectedTasks