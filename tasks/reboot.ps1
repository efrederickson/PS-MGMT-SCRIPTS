# reboot target
New-Task -Name reboot -ScriptBlock {
    shutdown /r /t 0
}