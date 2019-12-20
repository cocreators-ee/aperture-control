# First figure out if we need to update the files
$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent -Resolve
Write-Output "Running from $scriptDir"

$target = Split-Path -Path "$scriptDir" -Parent

Start-Transcript -Path "$target\update.log"

Write-Output "Aperture-control target path $target"

$repoPath = "$target\repo.txt"
$shaPath = "$target\sha.txt"

if (-Not (Test-Path $repoPath)) {
    Write-Output "Couldn't find $repoPath"
    exit
}

if (-Not (Test-Path $shaPath)) {
    Write-Output "Couldn't find $shaPath"
    exit
}

$repo = (Get-Content -Path "$repoPath").Trim()
$oldSha = (Get-Content -Path "$shaPath").Trim()
$apiUrl = "https://api.github.com/repos/$repo/commits/master"

Write-Output "Deployed from $repo (commit $oldSha)"
Write-Output "Checking for new commits from $apiUrl"

try {
    $response = Invoke-WebRequest $apiUrl -UseBasicParsing
    $sha = ($response.Content | ConvertFrom-Json).sha

    Write-Output "Latest commit is $sha"

    if ($sha -eq $oldSha) {
        Write-Output "No new commits."
        exit
    }
} catch {
    Write-Output "Failed to check for latest updates, retrying later."
    exit
}


# Then if there are updates, download them

Write-Output "New commits found - updating"

$url = "https://github.com/$repo/archive/master.zip"
$zip = "$env:USERPROFILE\Downloads\aperture-control.zip"

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
$repoName = $repo.Split("/")[1]

if (Test-Path "$target\$repoName-master") {
    Write-Output "Cleaning $target\$repoName-master"
    Remove-Item -Recurse -Force "$target\$repoName-master"
}
Write-Output "Extracting $zip to $target"
Unzip $zip $target

Write-Output "Running run-ac-recipes.ps1"
Start-Process -Wait -Verb runAs -ArgumentList "-ExecutionPolicy", "Bypass", "-NoLogo", "-NonInteractive", "-Command", "cd $acpath; .\run-ac-recipes.ps1" powershell.exe

Write-Output "Updating stored repostitory SHA hash to $sha"
"$sha" | Out-File "$shaPath"

Stop-Transcript
