# Runs a given Task on a given host
# Note: command CANNOT be interactive or it will hang indefinitely
# Task is the task name from the tasks module

function _RemoteDispatchCore {
    param(
        [parameter(Mandatory=$true)]$Hostname,
        [parameter(Mandatory=$true)]$Blocks,
        [PSCredential]$Credential
    )

    # This runs the block that kicks off the tasks on the remote hosts. 
    # The tasks are passed in as arguments and then turned (back) into ScriptBlock's and run. 

    $block = {
        foreach ($blk in $args) {
            # Run the actual task on the target computer

            $blk = "try { " + $blk + " } catch { return '__internal_psmgmtdispatch_failed_' + `$_  }"

            $res = Invoke-Command -ScriptBlock ([System.Management.Automation.ScriptBlock]::Create($blk))

            if ($res -ne $null) {
                #$res = $res.ToString()
                if ($res.ToString().StartsWith("__internal_psmgmtdispatch_failed_")) {
                    throw ($res -replace "__internal_psmgmtdispatch_failed_","")
                } else {
                    if ($res -is [System.Array]) {
                        $res | % { Write-Host $_ }
                    } else {
                        Write-Host $res.ToString()
                    }
                }
            }
        }
    }

    if ($Credential -ne $null) {
        Invoke-Command -ComputerName $Hostname -Credential $Credential -ScriptBlock $block -AsJob -ErrorVariable err -ArgumentList $Blocks -JobName $Hostname | Out-Null
    } else {
        Invoke-Command -ComputerName $Hostname -ScriptBlock $block -AsJob -ErrorVariable err -ArgumentList $Blocks -JobName $Hostname | Out-Null
    }

    # If an error occured say so. 
    if ($err -ne $null) {
        throw ("Error while remotely invoking command:" + $err + "for host:" + $Hostname)
    }
}

function RemoteDispatch-Task {
    param(
        [parameter(Mandatory=$true)]$Hostname,
        [parameter(Mandatory=$true)]$Task,
        [PSCredential]$Credential
    )

    $taskBlock = Get-InvokableTask -Name $Task
    _RemoteDispatchCore -Hostname $Hostname -Credential $Credential -Blocks @( taskBlock )
}

function RemoteDispatch-MultipleTasks {
    param(
        [parameter(Mandatory=$true)]$Hostname,
        [parameter(Mandatory=$true)]$Tasks,
        [PSCredential]$Credential
    )

    # Create a list of script blocks
    $blocks = @( )

    $Tasks | % {
        $blocks += Get-InvokableTask -Name $_
    }

    # So this is interesting: we have to run these consecutively so that tasks do not run out of order. parallelizing was originally
    # what happened until running "gpdupate reboot" caused them to reboot immediately. So now hosts are parallelized while tasks are not. 
    # At some point it may be worth adding flags to tasks for things like "destructiveActionCost", "needsReboot", runOrder, canRunParallel, etc

    _RemoteDispatchCore -Hostname $Hostname -Credential $Credential -Blocks $blocks
}

function RemoteDispatch-RawCommand {
    param(
        [parameter(Mandatory=$true)]$Hostname,
        [parameter(Mandatory=$true)]$Command,
        [PSCredential]$Credential
    )
    _RemoteDispatchCore -Hostname $Hostname -Credential $Credential -Blocks @( $Command )
}

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
        Write-Green "$taskRes/$taskCount tasks completed successfully."
    } else {
        Write-Red "$taskRes/$taskCount tasks completed successfully."
    }
}

function Execute-SelectedTasks {
    param(
        [Parameter(ValueFromPipeline=$true)]$SelectedTasks,
        [PSCredential]$Credential
    )

    _ExecuteCore { param($hostname) RemoteDispatch-MultipleTasks -Hostname $hostname -Credential $Credential -Tasks $SelectedTasks } -TaskName $SelectedTasks
}

function Execute-SelectedCommand {
    param(
        [Parameter(ValueFromPipeline=$true)]$Code,
        [PSCredential]$Credential
    )

    _ExecuteCore { param($hostname) RemoteDispatch-RawCommand -Hostname $hostname -Credential $Credential -Command $Code } -TaskName "raw-cmd"
}
