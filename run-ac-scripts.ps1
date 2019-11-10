#Requires -RunAsAdministrator

function label([string]$texter) {
    $len = $texter.Length

    $filler = "-" * $len
    $spacer = " " * $len

    Write-Host ""
    Write-Host ""
    Write-Host "/-$filler-\"
    Write-Host "| $spacer |"
    Write-Host "| $texter |"
    Write-Host "| $spacer |"
    Write-Host "\-$filler-/"
    Write-Host ""
}

# https://stackoverflow.com/a/50758683
function refresh-path {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") +
                ";" +
                [System.Environment]::GetEnvironmentVariable("Path","User")
}

label "Running ps-scripts\*.ps1"
Get-ChildItem "$pwd\ps-scripts" -Filter *.ps1 |
ForEach-Object {
    label $_
    powershell.exe -ExecutionPolicy Bypass -NoLogo -NonInteractive -File "ps-scripts\$_"

    # Update PATH if necessary
    refresh-path
}

label "Running cmd-scripts\*.ps1"
Get-ChildItem "$pwd\cmd-scripts" -Filter *.cmd |
ForEach-Object {
    label $_
    Invoke-Expression "cmd-scripts\$_"

    # Update PATH if necessary
    refresh-path
}

label "Applying registry\*.reg"
Get-ChildItem "$pwd\registry" -Filter *.reg |
ForEach-Object {
    label $_
    Invoke-Expression "regedit /s registry\$_"
}


Write-Host ""
Write-Host ""
Write-Host "Aperture Control finished."
Write-Host "You might want to restart your computer to finish installation and apply all the settings."
Start-Sleep -Seconds 30
