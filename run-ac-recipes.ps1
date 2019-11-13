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

Write-Host ""
Write-Host ""
Write-Host "Aperture Control finished."
Write-Host "You might want to restart your computer to finish installation and apply all the settings."
Start-Sleep -Seconds 30
