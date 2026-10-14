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
  - Point $ytdlp to your yt-dlp.exe executable.

  - Point $stagingDir and $archiveFile to your working directories.

  - Point $importScript to your local media import script or Beets workflow.

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