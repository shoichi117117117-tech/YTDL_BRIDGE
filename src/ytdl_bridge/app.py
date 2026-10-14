from flask import Flask, jsonify, request
from ytdl_bridge.executor import trigger_download

app = Flask(__name__)

@app.route("/", methods=["GET"])
def index():
  return jsonify({"status": "online", "service": "ytdl-bridge"}), 200

@app.route("/download", methods=["POST"])
def download_route():
  data = request.get_json() or {}
  url = data.get("url")

  if not url:
    return jsonify({"error": "No URL provided"}), 400

  try:
    trigger_download(url)
    return (
        jsonify(
            {
                "status": "success",
                "message": "Download triggered in background",
                "url": url,
            }
        ),
        202,
    )
  except Exception as e:
    return jsonify({"error": str(e)}), 500


if __name__ == "__main__":
  app.run(host="0.0.0.0", port=5000, debug=True)