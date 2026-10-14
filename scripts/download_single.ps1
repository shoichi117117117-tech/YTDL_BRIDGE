param(
    [Parameter(Mandatory=$true)]
    [string]$Url
)

# Load machine-specific paths from local config
. "$PSScriptRoot\..\local_config.ps1"

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

Add-Content -Path $log -Value "========================================"
Add-Content -Path $log -Value "Single URL Triggered at: $(Get-Date)"
Add-Content -Path $log -Value "URL: $Url"

# Step 1: Download single audio track via yt-dlp into staging directory
Write-Host "1/2: Downloading the song to Staging..." -ForegroundColor Cyan

# Run yt-dlp and capture output stream to inspect for archive skips
$ytdlpOutput = & $ytdlp `
    --no-playlist `
    --download-archive "$archiveFile" `
    -x --audio-format mp3 `
    --restrict-filenames `
    --embed-thumbnail `
    --convert-thumbnails jpg `
    --add-metadata `
    --embed-metadata `
    --no-mtime `
    -o "$stagingDir\%(uploader)s - %(title)s.%(ext)s" `
    $Url 2>&1


if ($LASTEXITCODE -eq 0) {
    # Check if the output indicates the file was skipped by the archive
    $isSkipped = $ytdlpOutput | Where-Object { $_ -match "has already been recorded in the archive" }    
    if ($isSkipped) {
        Write-Host "Status: Song is already downloaded and was skipped by archive." -ForegroundColor Yellow
        Add-Content -Path $log -Value "Status: Song already downloaded. Skipped by archive."
    } else {
        Add-Content -Path $log -Value "Status: yt-dlp download successful. Triggering importer..."
        
        Write-Host "2/2: Downloads complete. Running beets ingestion pipeline..." -ForegroundColor Cyan
        powershell.exe -ExecutionPolicy Bypass -File "$importScript"
        Write-Host "Pipeline execution completed!" -ForegroundColor Green
    }
} else {
    Write-Host "Error: yt-dlp failed to download the URL." -ForegroundColor Red 
    Add-Content -Path $log -Value "Error: yt-dlp failed to download the URL."
}