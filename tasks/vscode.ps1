New-Task -Name vscode -ScriptBlock {
    # This should install VSCode 

    # Map drive
    net use X: "\\ad\acdc utt" /user:student password

    # Run installer
    x:\Installers\VSCodeVSCodeUserSetup-x64-1.38.1.exe /verysilent

    # Wait for installer (since it detaches from console)
    while (Get-Process -Name "VSCodeUserSetup-x64-1.38.1" -ErrorAction SilentlyContinue) { 
        Start-Sleep -Seconds 5 
    }

    # Remove drive
    net use /del x:

    # Kill hanging processes
    Get-Process -Name Code -ErrorAction SilentlyContinue | Stop-Process -Force
}
