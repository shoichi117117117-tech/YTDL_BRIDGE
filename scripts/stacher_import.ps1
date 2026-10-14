param(
    [string]$FilePath
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

# Load machine-specific paths from your ytdl-bridge project config
. "$PSScriptRoot\..\local_config.ps1"

Add-Content -Path $log -Value "========================================"
Add-Content -Path $log -Value "PS1 Triggered at: $(Get-Date)"

Write-Host "=========================================================================================================================================" -ForegroundColor Cyan
Write-Host "Hello! I am beet." -ForegroundColor Cyan

# Path to your local beet executable
$beet = "C:\Users\<YourUsername>\.local\bin\beet.exe"

# Determine target path
if ($FilePath -and (Test-Path -LiteralPath $FilePath)) {
    $target = $FilePath
    Write-Host "Status: Processing single file '$target'..." -ForegroundColor Cyan
    Add-Content -Path $log -Value "Status: Processing single file '$target'..."
} else {
    $target = $stagingDir
    Write-Host "Status: Processing staging directory '$target'..." -ForegroundColor Cyan
    Add-Content -Path $log -Value "Status: Processing staging directory '$target'..."
}

# Run beets import
if (Test-Path -LiteralPath $target) {
    & $beet import -q "$target" *>> $log
} else {
    Write-Host "Status: Target path does not exist." -ForegroundColor Cyan
    Add-Content -Path $log -Value "Status: Target path does not exist."
}

# Post-Import Cleanup: Backfill empty album fields with the track's own Title
Write-Host "Status: Importing songs from Staging to Database." -ForegroundColor Cyan
Add-Content -Path $log -Value "Status: Backfilling empty album tags with track title..."
& $beet modify -y "album::^$" album='$title' *>> $log

Write-Host "Importing Execution complete. Good bye." -ForegroundColor Cyan
Write-Host "=========================================================================================================================================" -ForegroundColor Cyan

Add-Content -Path $log -Value "PS1 Execution complete."