import base64
import json
import logging
import os
import traceback
from pathlib import Path

import cv2
import numpy as np
from dotenv import load_dotenv
from flask import Flask, jsonify, request

from face_detect import check

# Optional file beside this module (e.g. bind-mount at runtime). Not baked into the image.
load_dotenv(Path(__file__).resolve().parent / ".env")

logging.basicConfig(
    level=os.environ.get("LOG_LEVEL", "INFO"),
    format="%(asctime)s %(levelname)s %(name)s %(message)s",
)
log = logging.getLogger(__name__)

app = Flask(__name__)


def _port() -> int:
    raw = os.environ.get("AVATAR_SERVICE_PORT") or os.environ.get("PORT") or "17001"
    try:
        return int(raw)
    except ValueError as e:
        raise ValueError(f"Invalid port value: {raw!r}") from e


def _debug() -> bool:
    return os.environ.get("FLASK_DEBUG", "true").lower() in ("1", "true", "yes")


def _parse_body():
    data = request.get_json(force=True, silent=True)
    if data is not None:
        return data
    raw = request.get_data()
    if not raw:
        return None
    try:
        return json.loads(raw.decode("utf-8"))
    except (json.JSONDecodeError, UnicodeDecodeError):
        return None


def _use_reloader() -> bool:
    """Werkzeug's debug reloader forks; that breaks many native libs (e.g. dlib) on WSL/macOS."""
    if not _debug():
        return False
    return os.environ.get("FLASK_USE_RELOADER", "").lower() in ("1", "true", "yes")


@app.route("/", methods=["GET"])
def root():
    return jsonify(
        service="ts-avatar-service",
        health="/health",
        avatar_post="/api/v1/avatar",
    ), 200


@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status": "ok"}), 200


@app.route("/api/v1/avatar", methods=["POST"], strict_slashes=False)
def avatar():
    data = _parse_body()
    if not isinstance(data, dict):
        return jsonify({"msg": "invalid or empty JSON body"}), 400

    image_b64 = data.get("img")
    if not image_b64:
        return jsonify({"msg": "need img in request body"}), 400

    try:
        image_decode = base64.b64decode(image_b64)
        nparr = np.frombuffer(image_decode, dtype=np.uint8)
        image = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
        if image is None:
            return jsonify({"msg": "could not decode image data"}), 400
        result = check(image)
    except Exception:
        log.exception("avatar processing failed")
        return jsonify({"msg": "exception:" + str(traceback.format_exc())}), 500

    if isinstance(result, dict) and result.get("msg") is not None:
        return jsonify(result), 400

    return result, 200


if __name__ == "__main__":
    bind_host = os.environ.get("AVATAR_SERVICE_HOST", "0.0.0.0")
    port = _port()
    use_reloader = _use_reloader()
    log.info(
        "Starting Flask on %s:%s (debug=%s, use_reloader=%s)",
        bind_host,
        port,
        _debug(),
        use_reloader,
    )
    app.run(host=bind_host, port=port, debug=_debug(), use_reloader=use_reloader)
