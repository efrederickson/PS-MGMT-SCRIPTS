# Get running processes
New-Task -Name processes -ScriptBlock {
    Get-Process | ForEach-Object { Write-Host $_.Id $_.Name $_.FileName }
}