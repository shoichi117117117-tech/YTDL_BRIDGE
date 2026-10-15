# yt-dlp Bridge

A lightweight Flask-based web bridge designed to receive YouTube links (via iOS Shortcuts or web clients), trigger automated `yt-dlp` audio downloads, and feed them into a `beets` media management pipeline.

---

## Features

- **Asynchronous Execution:** Spawns background PowerShell processes via Flask so your API never blocks or times out.
- **Smart Archiving:** Uses `yt-dlp` download archives to prevent duplicate downloads.
- **Automated Ingestion:** Automatically triggers your local `beets` script to ingest, tag, and clean up metadata.
- **Environment Isolation:** Uses local machine configurations to keep personal directory paths and secrets out of version control.

---

## Project Structure

```text
ytdl-bridge/
├── app.py                  # Main Flask application server
├── requirements.txt        # Python dependencies
├── .gitignore              # Ignores local configs, logs, and virtual environments
├── local_config.example.ps1# Template for machine-specific paths
└── scripts/
    ├── download_single.ps1 # Handles single URL downloads, archive checks, and script triggering
    └── stacher_import.ps1  # Handles beets import and metadata cleanup
```

---

## Setup & Installation

### 1. Clone the Repository

```bash
git clone https://github.com/your-username/ytdl-bridge.git
cd ytdl-bridge
```

### 2. Set Up Python Virtual Environment

```bash
python -m venv .venv
```

**On Windows (PowerShell):**
```powershell
.venv\Scripts\Activate
pip install -r requirements.txt
```

### 3. Configure Local Machine Paths

Because directory paths differ across machines, this project uses a local configuration file that is ignored by Git.

1. Copy the example configuration file:
   ```powershell
   Copy-Item local_config.example.ps1 local_config.ps1
   ```

2. Open `local_config.ps1` and update the paths to match your local setup:
   - Point `$ytdlp` to your `yt-dlp.exe` executable.
   - Point `$stagingDir` and `$archiveFile` to your working directories.
   - Point `$importScript` to your local media import script or Beets workflow.

---

## Usage

Start the Flask development server:

```bash
python app.py
```

Send a `POST` request to your endpoint with a JSON payload containing the YouTube URL:

```json
{
  "url": "https://www.youtube.com/watch?v=..."
}
```

---

## Architecture & Data Flow

This project serves as the core integration bridge for a fully automated, self-hosted music ingestion pipeline. When you share a track from your phone, it travels through a secure mesh network straight to your local library, fully tagged, cleaned, and organized.

### End-to-End Workflow

1. **[iOS Shortcuts](https://support.apple.com/guide/shortcuts/welcome/ios):** 
   * You share a YouTube URL from your device. The iOS Shortcut fires an HTTP `POST` request containing the URL.
2. **[Tailscale](https://tailscale.com/):** 
   * Tunnels the request securely from your mobile device to your home server or development machine over a private, encrypted connection without exposing ports publicly.
3. **`ytdl-bridge` (Flask API Server):** 
   * Receives the JSON payload, checks the `yt-dlp` download archive to avoid duplicate downloads, and asynchronously spawns a background PowerShell execution script.
4. **[yt-dlp](https://github.com/yt-dlp/yt-dlp):** 
   * Downloads the highest-quality audio stream and stages the raw file locally.
5. **[beets](https://beets.io/):** 
   * Automatically ingests the staged audio file and runs it through a robust plugin and matching suite:
     * **Audio Fingerprinting ([AcoustID](https://acoustid.org/) & [Chromaprint](https://acoustid.org/chromaprint)):** Automatically identifies unknown or messy tracks using acoustic matching.
     * **Metadata & Normalization ([MusicBrainz](https://musicbrainz.org/), `ftintitle`, `scrub`):** Queries MusicBrainz, strips featured artists from track titles into clean feature fields, and scrubs old junk metadata.
     * **Artwork & Lyrics ([LRCLib](https://lrclib.net/), `fetchart`, `embedart`):** Automatically fetches high-resolution cover art (from Cover Art Archive, iTunes, Amazon, or local files), embeds it directly into the audio file, and pulls synchronized time-stamped lyrics.
     * **Genres & Formatting (`lastgenre`, Custom Rules):** Normalizes genres automatically and applies smart fallback rules (e.g., placing singles into an organized directory structure under your Google Drive music library).
6. **[Navidrome](https://www.navidrome.org/):** 
   * Instantly indexes the freshly tagged and organized files, making them immediately available for streaming on all your devices.

---

### Pipeline Component Summary

| Component | Role | Technology / Tool |
| :--- | :--- | :--- |
| **Remote Trigger** | Sends link from mobile | [iOS Shortcuts](https://support.apple.com/guide/shortcuts/welcome/ios) / REST API |
| **Secure Transport** | Private remote routing | [Tailscale](https://tailscale.com/) |
| **API Web Hook** | Non-blocking execution server | Python Flask (`ytdl-bridge`) |
| **Downloader** | Fetches source audio | [yt-dlp](https://github.com/yt-dlp/yt-dlp) |
| **Tagger & Organizer** | Fingerprinting, lyrics, art, and clean directory paths | [beets](https://beets.io/) (with AcoustID, Chroma, LRCLib, etc.) |
| **Streaming Server** | Personal music library streaming | [Navidrome](https://www.navidrome.org/) |