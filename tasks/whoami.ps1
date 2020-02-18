New-Task -Name whoami -ScriptBlock {
    #whoami
    return [system.Environment]::UserDomainName + "\" + [System.Environment]::UserName
}