# Run gpupdate
New-Task -Name gpupdate -ScriptBlock {
    gpupdate.exe /force /logoff
}