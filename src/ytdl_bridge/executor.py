import subprocess
import os


def trigger_download(youtube_url: str):
  """Triggers the PowerShell sync script asynchronously in the background,

  passing the YouTube URL as an argument.
  """
  ps_script_path = (
    "scripts/download_single.ps1"
  )

  if not os.path.exists(ps_script_path):
    raise FileNotFoundError(f"PowerShell script not found at {ps_script_path}")

  # Spawn the background process without blocking Flask
  subprocess.Popen([
      "powershell.exe",
      "-ExecutionPolicy",
      "Bypass",
      "-File",
      ps_script_path,
      "-Url",
      youtube_url,
  ])