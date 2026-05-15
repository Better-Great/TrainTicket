import base64
import logging
import os

import cv2
import numpy as np

log = logging.getLogger(__name__)

_path_save = os.environ.get("AVATAR_FACE_IMAGE_DIR", "./images/")
_save_debug = os.environ.get("AVATAR_SAVE_DEBUG_IMAGES", "false").lower() in (
    "1",
    "true",
    "yes",
)

_cascade = None


def _get_cascade():
    global _cascade
    if _cascade is None:
        path = cv2.data.haarcascades + "haarcascade_frontalface_default.xml"
        log.info("loading OpenCV Haar cascade face detector")
        _cascade = cv2.CascadeClassifier(path)
        if _cascade.empty():
            raise RuntimeError(f"cascade load failed: {path}")
    return _cascade


def check(img):
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    faces = _get_cascade().detectMultiScale(
        gray, scaleFactor=1.1, minNeighbors=5, minSize=(30, 30)
    )
    log.debug("face count: %s", len(faces))

    if len(faces) < 1:
        return {"msg": "no human face found"}

    x, y, w, h = max(faces, key=lambda f: f[2] * f[3])
    crop = np.ascontiguousarray(img[y : y + h, x : x + w])

    if _save_debug:
        os.makedirs(_path_save, exist_ok=True)
        out_path = os.path.join(_path_save, "img_face_1.jpg")
        log.debug("Save to: %s", out_path)
        cv2.imwrite(out_path, crop)

    encoded = cv2.imencode(".jpg", crop)[1].tobytes()
    return base64.b64encode(encoded)
