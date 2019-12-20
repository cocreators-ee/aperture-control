#Requires -RunAsAdministrator

$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent -Resolve
Write-Output "Running from $scriptDir"

$target = Split-Path -Path "$scriptDir" -Parent

Start-Transcript -Path "$target\run.log"

function label([string]$texter) {
    $len = $texter.Length

    $filler = "-" * $len
    $spacer = " " * $len

    Write-Output ""
    Write-Output ""
    Write-Output "/-$filler-\"
    Write-Output "| $spacer |"
    Write-Output "| $texter |"
    Write-Output "| $spacer |"
    Write-Output "\-$filler-/"
    Write-Output ""
}

# https://stackoverflow.com/a/50758683
function refresh-path {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") +
                ";" +
                [System.Environment]::GetEnvironmentVariable("Path","User")
}

label "Running recipes..."
Get-ChildItem "$pwd\recipes" |
ForEach-Object {
    if ($_ -eq ".gitkeep") {
        continue
    }

    $extension = [IO.Path]::GetExtension($_)
    if ($extension -eq ".ps1") {
        label "$_ PowerShell script"
        powershell.exe -ExecutionPolicy Bypass -NoLogo -NonInteractive -File "recipes\$_"
    } elseif ($extension -eq ".cmd") {
        label "$_ Batch script"
        Invoke-Expression "recipes\$_"
    } elseif ($extension -eq ".reg") { 
        label "$_ Registry patch"
        Invoke-Expression "regedit /s registry\$_"
    } else {
        label "Skipping $_ - unsupported extension."
    }

    # Update PATH if necessary
    refresh-path
}

Write-Output ""
Write-Output ""
Write-Output "Aperture Control finished."
Write-Output "You might want to restart your computer to finish installation and apply all the settings."
Start-Sleep -Seconds 30

Stop-Transcript
