Import-Module -DisableNameChecking -Force $PSScriptRoot\core.psm1
Import-Module -DisableNameChecking -Force $PSScriptRoot\core-ui.psm1
Import-Module -DisableNameChecking -Force $PSScriptRoot\lib\common.psm1
Expand-RelativeLibPaths hosts RemoteDispatch tasks threading Write-Colors | % { Import-Module -DisableNameChecking -Force $_ }

Load-Tasks -Directory $PSScriptRoot\tasks
Load-Hosts -File $PSScriptRoot\hosts

$script:selectedTasks = @( "hostname" )
$script:impersonatedCreds = $null

function Process-Input {
    $choice = Read-Host -Prompt "Selection"

    if ($choice -eq "0" -or $choice -eq "q" -or $choice -eq "quit" -or $choice -eq "exit") {
        # Save host list and exit
        Save-Hosts -File $PSScriptRoot\hosts
        exit
    } elseif ($choice -eq "1") {
        # Prompt for host and add it
        $selHost = Read-Host -Prompt "Host to add"
        if (Get-Hosts -contains $selHost -eq $false) {
            Add-Host $selHost
        } else {
            Write-Host "Host already exists"
        }
    } elseif ($choice -eq "2") {
        # Prompt for host and remove it
        $selHost = Read-Host -Prompt "Host to remove"
        if (Get-Hosts -contains $selHost) {
            Remove-Host $selHost
        } else {
            Write-Host "Host does not exist"
        }
    } elseif ($choice -eq "3") {
        # Prompt for task and add it if it is valid
        $selTask = Read-Host -Prompt "Task to add"
        if ((Get-TaskNames).contains($_)) {
            Write-Green "Adding task $selTask"
            $script:selectedTasks += $selTask
        } else {
            Write-Red "Task does not exist"
        }
    } elseif ($choice -eq "4") {
        # Prompt for task and remove it if it is valid
        $selTask = Read-Host -Prompt "Task to remove"
        if ($script:selectedTasks -contains $selTask) {
            $script:selectedTasks = $script:selectedTasks -ne $selTask
        } else {
            Write-Red "Task does not exist"
        }
    } elseif ($choice -eq "5") {
        # Prompt for task list and add valid ones, overwriting previous list
        # Easier than removing/adding a whole list of tasks.
        $selTasks = Read-Host -Prompt "Tasks to set"
        $script:selectedTasks = @( )
        $selTasks -split " " | % {
            if ((Get-TaskNames).contains($_)) {
                Write-Green "Adding task $_"
                $script:selectedTasks += $_
            } else {
                Write-Red "Task $_ does not exist"
            }
        }
    } elseif ($choice -eq "6") {
        # Impersonate user
        $creds = Get-Credential -ErrorAction SilentlyContinue
        if ($creds -ne $null) {
            Write-Green "Using credentials for" $creds.Username
            $script:impersonatedCreds = $creds
        }
    } elseif ($choice -eq "7") {
        if ($script:impersonatedCreds -ne $null) {
            Write-Green "Dropped credentials"
            $script:impersonatedCreds = $null
        }
    } elseif ($choice -eq "8" -or $choice -match "^exe" -or $choice -eq "run") {
        # Kick off tasks
        Execute-SelectedTasks -Credential $script:impersonatedCreds -SelectedTasks $script:selectedTasks
    } elseif ($choice -eq "9" -or $choice -eq "raw") {
        # This prompts for and runs a block of code from stdin
        $code =
        Execute-SelectedCommand -Credential $script:impersonatedCreds -Code (Read-Host -Prompt "Cmd")
    }
}

# Loop forever until user quit
while (1) {
    Write-Header -SelectedTasks $script:selectedTasks -ImpersonatedUser $script:impersonatedCreds.UserName
    Write-Menu
    Process-Input
}