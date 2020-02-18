# ACDC POWERSHELL MANAGEMENT SCRIPTS

These scripts can be used to remotely execute commands on the hosts in the ACDC AD domain. Or any domain or set of computers with PowerShell Remoting enabled. 
You should not be prompted for authentication, nor should authentication fail, because of running as domain admin (or other domain user). 

It is imperative to read this whole document before executing the scripts. At some point there will be visual aids for the crayon eaters and those unable to process words.

Primary info: run `interactive.ps1` (right click -> run) and use the options to set and run the task you need. For example to gpupdate and reboot:

```
5
gpupdate reboot
run
```

`5` currently corresponds to the option to "set tasks". 

These scripts are fairly uncomplicated as of yet, runs just what it needs to, minimal error checking or input validation. As time goes on this may change. 
Also this simplicity means it shouldn't be too hard to understand what the code does. Basic workflow is like so:

```
USER -> INTERACTIVE START TASKS -> CONVERT TASKS TO CODE -> DISPATCH (Invoke-Command) (SEND CODE TO TARGET HOSTS) ->
  -> WAIT FOR TASKS TO COMPLETE REMOTELY AND WRITE OUTPUT AS THEY FINISH
```

## 0. PowerShell Remoting Configuration: 

NOTE THAT THIS IS DONE VIA GPO AND SHOULD NOT HAVE TO BE RUN MANUALLY

PRECONFIGURATION STEPS (RUN ON TARGET COMPUTER IN ADMIN CMD):
`winrm qc`
ANSWER `y` TO ALL PROMPTS

Alternatively, or if it does not work / stops working:
```
Get-PSSessionConfiguration -Name Microsoft.PowerShell | Unregister-PSSessionConfiguration
Enable-PSRemoting -Force
```

## 1. Running

### Interactively

```
powershell .\interactive.ps1
```

From here you can follow the prompts to add/remove hosts, add/remove tasks to run, and then execute the selected tasks. 

You can also run raw code (like what you would put in a tasks file). This can be useful for things like prototyping tasks or running a quick one-off command.
If the command is run more than once though it doesn't hurt to put it in a task. Again, you can not run interactive commands this way!!

### Automatically

```
powershell .\automatic.ps1 <task names>
```

Assuming all of the tasks exist, it will run them on all the hosts in the `hosts` file. TODO: flush out this file more (options, etc)

## 2. Adding tasks

In the `tasks` folder, there are a series of ps1 files that follow these guidelines:
```
New-Task -Name <single word descriptor> -ScriptBlock {
    <commands>
}
```

`<commands>` are PowerShell commands that will be executed ON THE REMOTE TARGET. 
!!! THESE COMMANDS CANNOT BE (CLI) INTERACTIVE OR IT WILL HANG INDEFINITELY !!!

You can run commands like `hostname.exe` or Cmdlets like `Get-ChildItem -Recurse -Path C:\\`. Note that redirection will not redirect to the host but will write to a file on the remote target.

The filename of the task ps1 is irrelevant. The name given to `New-Task -Name` is what matters.

## 3. Troubleshooting

TODO