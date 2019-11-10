# Aperture Control - Windows environment automation

This is a set of scripts to help automate your Windows installations. It's intended to be used by forking and customizing the repository to your needs. It is not intended as a tool for the general public, some understanding of command line utilities, registry, and such is required for efficient usage.

With well designed scripts, it can maintain your various systems in the desired state over time and minimize the hassle of taking new computers into use.

You can also use it to e.g. deploy various common tools to your fellow developers working in the same project, or distribute software and basic settings for all your employees without resorting to the pretty abusive domain level controls over the computers.

This has been tested on Windows 10 Professional. No promises about it working under anything else (but please do send feedback if you are successful in other environments as well).


## How to run Aperture Control

First, fork this repo and edit the contents of `cmd-scripts`, `ps-scripts`, and `registry` to match your needs. Then launch PowerShell as Administrator and paste this in it (editing the last bit for the repository).

```
Set-ExecutionPolicy -ExecutionPolicy Unrestricted
(New-Object System.Net.WebClient).DownloadFile('https://raw.githubusercontent.com/Lieturd/aperture-control/master/setup.ps1', 'setup.ps1'); .\setup.ps1 lieturd/aperture-control
```

It seems Windows installations by default block PowerShell scripts, which is pretty weird considering they want to promote the tool as "the" scripting tool for Windows, which is why you need to unrestrict the execution policy before running Aperture Control.

Simply what happens is that it downloads the [setup.ps1](./setup.ps1) -script and executes it with your repository as the argument so it knows where to download your configuration.

Alternatively, if you don't want your configuration to be public, just copy it from your favorite secure storage, and run the `run-ac-scripts.ps1` -script as Administrator.

**PLEASE NOTE:** Installing a lot of things with this may take a while, and your computer might launch or close various things you are already running. This is best run with a clean system, or right after starting Windows, and letting it do it's thing. Also restarting afterwards might be necessary to finish some installations, to activate various registry changes, and so on.


## What does it really do?

Simply put, it runs a number of PowerShell and cmd scripts to set up your environment, and is able to apply registry patches as well.

In more detail:
1. The `setup.ps1` script is downloaded with the command above and executed
2. `setup.ps1` downloads the complete repository from GitHub, unzips it to `%USERPROFILE%\aperture-control` and executes `run-ac-scripts.ps1` with Administrator permissions
3. `run-ac-scripts.ps1` loops through `ps-scripts` and executes them with PowerShell
4. `run-ac-scripts.ps1` loops through `cmd-scripts` and executes them with `cmd.exe`
5. `run-ac-scripts.ps1` loops through `registry` and applies them with `regedit.exe`

The examples provided here use [Chocolatey](https://chocolatey.org) and [Scoop](https://scoop.sh) package managers to install various things. You may want to take a look into the things they support if you want to make your life easier.


## Words of warning

Do not trust random scripts on the internet, including these. Check them for yourself, make sure you understand what is going on, and that you have reasonable reason to trust them and have control over what is running on your PC.

Do not use other people's repositories for your configuration, as they may change them, and the scripts can execute anything with administrator permissions without you noticing.


# License

Short answer: This software is licensed with the BSD 3-clause -license.

Long answer: The license for this software is in [LICENSE.md](./LICENSE.md), the other pieces of software installed and used have varying other licenses that you need to be separately aware of.
