from ytdl_bridge.executor import trigger_download

# Use a safe, short test URL
test_url = "PLEASE_PASTE_YOUTUBE_URL"

print(f"Triggering download script for: {test_url}")
try:
  trigger_download(test_url)
  print("Successfully sent signal to PowerShell script in the background!")
except Exception as e:
  print(f"Error occurred: {e}")