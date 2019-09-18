function Process-Job {
    param([System.Management.Automation.Job]$Job)

    Write-Host Processing job $Job.Name

    Receive-Job -Job $Job | Write-Host
    Remove-Job -Job $Job

    if ($job.State -eq "Completed") {
        return 1
    }
    return 0
}

function Process-Jobs {
#write-host proc jobs enter
    $count = 0

    $jobs = Get-Job -State Completed 
    #write-host job comp $jobs.length
    $jobs | % { 
        $count += (Process-Job -Job $_)
    }

    $jobs = Get-Job -State Failed
    #write-host job failed $jobs.length
    $jobs | % { 
        $count += (Process-Job -Job $_)
    }

    $jobs = Get-Job -State Disconnected
    #write-host job disconn $jobs.length
    $jobs | % { 
        $count += (Process-Job -Job $_)
    }
    #write-host proc jobs exit
    return $count
}

function WaitFor-Jobs {
    $success = 0

    while (Get-Job -State Running) {
        Start-Sleep -Milliseconds 100
        #Write-Host While loop p1
        $success += Process-Jobs
        #Write-Host While loop p2
    }

    $success += Process-Jobs


    return $success
}

for ($i = 0; $i -lt 10; $i += 1) {
    Start-Job -ScriptBlock { param($i); Start-Sleep -Seconds $i; Write-Host "Hello, I am job $i" } -ArgumentList $i
}

write-host "Waiting..."
WaitFor-Jobs