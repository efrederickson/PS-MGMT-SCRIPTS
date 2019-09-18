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
            Invoke-Command -ScriptBlock ([System.Management.Automation.ScriptBlock]::Create($blk))
        }
    }

    if ($Credential -ne $null) {
        Invoke-Command -ComputerName $Hostname -Credential $Credential -ScriptBlock $block -AsJob -ErrorVariable err -ArgumentList $Blocks | Out-Null
    } else {
        Invoke-Command -ComputerName $Hostname -ScriptBlock $block -AsJob -ErrorVariable err -ArgumentList $Blocks | Out-Null
    }

    # If an error occured say so. 
    if ($err -ne $null) {
        Write-Error "Error while remotely invoking command: " $err
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
        [parameter(Mandatory=$true)]$Command
    )
    _RemoteDispatchCore -Hostname $Hostname -Credential $Credential -Blocks @( $Command )
}
