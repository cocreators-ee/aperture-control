if (Get-Command choco.exe -ErrorAction SilentlyContinue) {
    Write-Host "Chocolatey already installed, upgrading instead."
    choco.exe upgrade chocolatey
} else {
    Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}
