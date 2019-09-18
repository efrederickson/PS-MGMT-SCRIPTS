# Get running processes
New-Task -Name processes -ScriptBlock {
    Get-Process | % { Write-Host $_.Id $_.Name $_.FileName }
}