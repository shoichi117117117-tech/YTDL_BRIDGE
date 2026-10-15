<#
.SYNOPSIS
    Example Local Configuration Template for ytdl-bridge
.DESCRIPTION
    Copy this file, rename it to local_config.ps1, and update 
    the paths to match your local machine setup.
#>

$global:stagingDir   = "C:\Users\<YourUsername>\Music\Staging"
$global:log          = "C:\Users\<YourUsername>\Projects\ytdl-bridge\logs\stacher_import.log"
$global:ytdlp        = "C:\Users\<YourUsername>\.stacher\yt-dlp.exe"
$global:archiveFile  = "C:\Users\<YourUsername>\Music\downloaded_archive.txt"
$global:importScript = "$PSScriptRoot\scripts\stacher_import.ps1"