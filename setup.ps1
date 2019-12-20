param([string]$repo)  

$repoName = $repo.Split("/")[1]
$url = "https://github.com/$repo/archive/master.zip"
$zip = "$env:USERPROFILE\Downloads\aperture-control.zip"
$target = "$env:USERPROFILE\aperture-control" 

New-Item -ItemType Directory -Force -Path $target
Start-Transcript -Path "$target\setup.log"
    
# https://stackoverflow.com/a/27768628
Add-Type -AssemblyName System.IO.Compression.FileSystem
function Unzip {
    param([string]$zipfile, [string]$outpath)

    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}

Write-Output "Downloading $url to $zip"
if (Test-Path $zip) {
    Remove-Item -Force $zip
}
$wc = New-Object System.Net.WebClient
$wc.DownloadFile($url, $zip)

if (Test-Path $target) {
    Write-Output "Cleaning $target"
    Remove-Item -Recurse -Force $target
}
Write-Output "Extracting $zip to $target"
Unzip $zip $target

$response = Invoke-WebRequest "https://api.github.com/repos/$repo/commits/master" -UseBasicParsing
$sha = ($response.Content | ConvertFrom-Json).sha

# Save source repo information
"$repo" | Out-File "$target\repo.txt"
"$sha" | Out-File "$target\sha.txt"

# Elevate to Administrator and continue
$acpath = "$target\$repoName-master"
Write-Output "Launching $acpath\run-ac-recipes.ps1 as Administrator"
Start-Process -Wait -Verb runAs -ArgumentList "-ExecutionPolicy", "Bypass", "-NoLogo", "-NonInteractive", "-Command", "cd $acpath; .\run-ac-recipes.ps1" powershell.exe

# Set up recurring task to update
$when = (Get-Date).AddHours(1)
$span = New-TimeSpan -Days 3650
$every = New-TimeSpan -Hours 1

$trigger = New-ScheduledTaskTrigger -Once -At $when -RepetitionDuration $span -RepetitionInterval $every -ThrottleLimit 1
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -NoLogo -NonInteractive -Command .\update.ps1 > $target\latest.txt" -WorkingDirectory $acpath
$principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType "S4U" -RunLevel Highest

Write-Output "Configuring auto-updates via Task Scheduler"
Register-ScheduledTask -TaskName "ApertureControlUpdate" -ThrottleLimit 1 -Action $action -Trigger $trigger -Principal $principal -Force

Stop-Transcript
