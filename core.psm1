function _ExecuteCore {
    param(
        [Parameter(ValueFromPipeline=$true)]$block,
        $TaskName = ""
    )

    $taskCount = 0
    Get-Hosts | % { 
        $taskCount += 1
        Write-Yellow "Dispatching job(s) $TaskName to $_" 
        Invoke-Command -ScriptBlock $block -ArgumentList $_
    }
    Write-Host Waiting for jobs to complete...
    Write-Host ""

    $taskRes = WaitFor-Jobs
    Write-Host ""
    if ($taskCount -eq $taskRes) {
        Write-Green "$taskCount tasks completed successfully."
    } else {
        Write-Red "$taskRes/$taskCount tasks completed successfully."
    }
}

function Execute-SelectedTasks {
    param([Parameter(ValueFromPipeline=$true)]$SelectedTasks)

    _ExecuteCore { param($hostname) RemoteDispatch-MultipleTasks -Hostname $hostname -Tasks $SelectedTasks } -TaskName $SelectedTasks
}

function Execute-SelectedCommand {
    param([Parameter(ValueFromPipeline=$true)]$Code)

    _ExecuteCore { param($hostname) RemoteDispatch-RawCommand -Hostname $hostname -Command $Code } -TaskName "raw-cmd"
}
