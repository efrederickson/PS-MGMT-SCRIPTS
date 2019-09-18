$Script:Tasks = @{ }

function Get-InvokableTask {
    param(
        [parameter(Mandatory=$true)]$Name
    )

    return $Script:Tasks[$Name]
}

function New-Task {
    param(
        [parameter(Mandatory=$true)]$Name,
        [parameter(Mandatory=$true)]$ScriptBlock
    )

    if ($Script:Tasks[$Name] -ne $null) {
        Write-Error "Task already exists with name: $Name"
        return
    }

    $Script:Tasks[$Name] = $ScriptBlock
}

function Load-Tasks {
    param(
        [parameter(Mandatory=$true)]$Directory
    )

    Get-ChildItem $Directory -Filter *.ps1 | % {
        . $_.FullName
    }
}

function Get-TaskNames {
    return $Script:Tasks.Keys
}
