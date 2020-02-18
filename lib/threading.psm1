# Small library to handle waiting for and processing PS jobs

# Write output of job, remote job, return 1 if successful
function Process-Job {
    param([System.Management.Automation.Job]$Job)

    Write-Yellow Processing job $Job.Name

    Receive-Job -Job $Job | Write-Host
    Remove-Job -Job $Job

    if ($job.State -eq "Completed") {
        return 1
    }
    return 0
}

# Process all finished jobs (completed, failed, etc)
function Process-Jobs {
    $count = 0

    $jobs = Get-Job -State Completed 
    $jobs | % { 
        $count += (Process-Job -Job $_)

    }

    $jobs = Get-Job -State Failed
    $jobs | % { 
        $count += (Process-Job -Job $_)
    }

    $jobs = Get-Job -State Disconnected
    $jobs | % { 
        $count += (Process-Job -Job $_)
    }

    return $count
}

# Returns number of successful jobs
function WaitFor-Jobs {
    $success = 0

    while (Get-Job -State Running) {
        Start-Sleep -Milliseconds 100

        $success += Process-Jobs
    }

    $success += Process-Jobs

    return $success
}