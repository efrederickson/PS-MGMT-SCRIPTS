# Get target hostname
New-Task -Name hostname -ScriptBlock {
    hostname.exe
}