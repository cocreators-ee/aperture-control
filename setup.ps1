param([string]$repo)  

$url = "https://github.com/$repo/archive/master.zip"
$zip = "$env:USERPROFILE\Downloads\aperture-control.zip"
$target = "$env:USERPROFILE\aperture-control" 

# https://stackoverflow.com/a/27768628
Add-Type -AssemblyName System.IO.Compression.FileSystem
function Unzip {
    param([string]$zipfile, [string]$outpath)

    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}

Write-Host "Downloading $url to $zip"
Remove-Item -Force $zip -ErrorAction SilentlyContinue
$wc = New-Object System.Net.WebClient
$wc.DownloadFile($url, $zip)

Write-Host "Cleaning $target"
Remove-Item -Recurse -Force $target -ErrorAction SilentlyContinue
Write-Host "Extracting $zip to $target"
Unzip $zip $target

# Elevate to Administrator and continue
# TODO: Get "aperture-control" name from repo name argument
Write-Host "Launching $target\aperture-control-master\run-ac-recipes.ps1 as Administrator"
Start-Process -Wait -Verb runAs -ArgumentList "-ExecutionPolicy", "Bypass", "-NoLogo", "-NonInteractive", "-Command", "cd $target\aperture-control-master; .\run-ac-recipes.ps1" powershell.exe
