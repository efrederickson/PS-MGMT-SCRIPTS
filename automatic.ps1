# Automatically process tasks to run

[CmdletBinding(PositionalBinding=$false)]
param(
    [Parameter(ValueFromPipeline=$true,ValueFromRemainingArguments=$true)]$Tasks,
    [Parameter(ValueFromPipeline=$false)]$Hosts
)

Import-Module -DisableNameChecking -Force $PSScriptRoot\core-ui.psm1
Import-Module -Force $PSScriptRoot\lib\common.psm1
Expand-RelativeLibPaths hosts RemoteDispatch tasks threading Write-Colors | % { Import-Module -DisableNameChecking -Force $_ }

Load-Tasks -Directory $PSScriptRoot\tasks

if ($Hosts -ne $null -and $Hosts.Count -gt 0) {
    Set-Hosts -Hosts $Hosts
} else {
    Load-Hosts -File $PSScriptRoot\hosts
}

# set tasks & verify tasks
$script:selectedTasks = @( )

$Tasks | % {
    if ($_ -ne $null -and $_.Length -gt 0 -and (Get-TaskNames).contains($_)) {
        Write-Green "Adding task $_"
        $script:selectedTasks += $_
    } elseif ($_ -ne $null -and $_.Length -gt 0) {
        Write-Red "Task $_ does not exist"
        exit 1
    }
}

if ($script:selectedTasks.Count -gt 0) {
    Write-Header -SelectedTasks $script:selectedTasks
    Execute-SelectedTasks -SelectedTasks $script:selectedTasks
} else {
    Write-Red "No tasks selected"
}