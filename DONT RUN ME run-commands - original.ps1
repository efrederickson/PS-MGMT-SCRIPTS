### Author: SGT Frederickson
### Date: 13 SEP 2019
### Version: 20190913001
### Purpose: Remotely manage computers in the AD
### 
### Notes:
### It should not need credentials if you run as domain admin as all targets should be joined to the domain.
### Interactive commands will hang indefinitely. Don't use a timeout if the command or connection is just slow it will screw things up.
### 
### 
### PRECONFIGURATION STEPS (RUN ON TARGET COMPUTER IN ADMIN CMD):
### winrm qc
### ANSWER "Y" TO ALL PROMPTS
### Alternatively, or if it does not work:
### Get-PSSessionConfiguration -Name Microsoft.PowerShell | Unregister-PSSessionConfiguration && Enable-PSRemoting -Force
### NOTE THAT IS DONE VIA GPO AND SHOULD NOT HAVE TO BE RUN MANUALLY
### 

Import-Module $PSScriptRoot\lib\common.ps1
Expand-RelativeLibPaths threading Write-Colors | % { Import-Module $_ }

# List of the computers to run commands on
$computers = @(
    "lane-01",
    "lane-02",
    "lane-03",
    "lane-04",
    "lane-05",
    "lane-06",
    "lane-07",
    "lane-08",
    "lane-09",
    "lane-10"
)

### 
### WARNING: If the command is interactive, the script will hang indefinitely.
### 

# Enumerate through all of the computers
$computers | % { 
    Start-Job -ScriptBlock {
        param($computerName)

        # Run commands locally on the target. $_ is the implicit variable for the enumerator
        Invoke-Command -ComputerName $computerName -ScriptBlock {
            # This will show you as it moves on to different hosts
            # Also verifies it's alive
            hostname.exe
        
            # Some common tasks:

            # Update Group Policy and reboot:
            # gpupdate.exe /force /logoff
            # shutdown /r /t 0

            # Get IP addresses:
            #Get-NetIPAddress | select IPAddress
        } # > C:\reports\$_.txt

        # You can run commands that take remote parameters too:
        # shutdown /m \\$_ /r /t 0
    } -ArgumentList $_
}

# Wait for async data to come back

WaitFor-Jobs