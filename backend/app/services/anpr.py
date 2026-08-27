from pathlib import Path
import threading
import cv2
import numpy as np
from fastapi import HTTPException
from app.core.config import get_settings
from app.services.plate import normalize_plate, plate_shape_score

settings = get_settings()
_model = None
_ocr = None
_lock = threading.Lock()

def model_available():
    return Path(settings.model_path).exists()

def _load_models():
    global _model, _ocr
    if _model is not None and _ocr is not None:
        return
    with _lock:
        if _model is not None and _ocr is not None:
            return
        if not model_available():
            raise HTTPException(
                status_code=503,
                detail=f"ANPR model missing. Copy best.pt to {settings.model_path}.",
            )
        from ultralytics import YOLO
        import easyocr
        _model = YOLO(settings.model_path)
        _ocr = easyocr.Reader(["en"], gpu=False)

def _decode(raw):
    arr = np.frombuffer(raw, dtype=np.uint8)
    image = cv2.imdecode(arr, cv2.IMREAD_COLOR)
    if image is None:
        raise HTTPException(status_code=400, detail="Invalid image.")
    return image

def _variants(crop):
    h, w = crop.shape[:2]
    if not h or not w:
        return []
    scale = max(2.0, 600.0 / max(w, 1))
    enlarged = cv2.resize(crop, None, fx=scale, fy=scale, interpolation=cv2.INTER_CUBIC)
    gray = cv2.cvtColor(enlarged, cv2.COLOR_BGR2GRAY)
    gray = cv2.bilateralFilter(gray, 7, 50, 50)
    enhanced = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8,8)).apply(gray)
    thresholded = cv2.adaptiveThreshold(
        enhanced, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, cv2.THRESH_BINARY, 31, 7
    )
    return [enhanced, thresholded]

def _ocr_best(crop):
    candidates = []
    for image in _variants(crop):
        results = _ocr.readtext(
            image, detail=1, paragraph=False,
            allowlist="ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        )
        items = []
        for bbox, text, conf in results:
            cleaned = normalize_plate(text)
            if not cleaned:
                continue
            x = min(p[0] for p in bbox)
            y = min(p[1] for p in bbox)
            items.append((float(x), float(y), cleaned, float(conf)))
        items.sort(key=lambda r: (round(r[1]/40), r[0]))

        for _, _, text, conf in items:
            candidates.append((conf + plate_shape_score(text), text, conf))

        for start in range(len(items)):
            for end in range(start + 2, min(len(items), start + 3) + 1):
                group = items[start:end]
                text = normalize_plate("".join(row[2] for row in group))
                avg = sum(row[3] for row in group) / len(group)
                candidates.append((avg + plate_shape_score(text), text, avg))

    if not candidates:
        raise HTTPException(status_code=422, detail="Plate detected but OCR could not read it.")

    candidates.sort(key=lambda r: r[0], reverse=True)
    _, plate, conf = candidates[0]
    if conf < settings.ocr_min_confidence or plate_shape_score(plate) < 0:
        raise HTTPException(status_code=422, detail=f"Low-confidence OCR result: {plate}")
    return plate, conf

def recognize_plate(raw: bytes):
    _load_models()
    image = _decode(raw)
    predictions = _model.predict(
        source=image, conf=settings.anpr_confidence, imgsz=640, verbose=False
    )
    result = predictions[0]
    if result.boxes is None or len(result.boxes) == 0:
        raise HTTPException(status_code=422, detail="No number plate detected.")

    confs = result.boxes.conf.detach().cpu().numpy()
    idx = int(np.argmax(confs))
    x1,y1,x2,y2 = result.boxes.xyxy[idx].detach().cpu().numpy().astype(int).tolist()
    h,w = image.shape[:2]
    px,py = max(4,int((x2-x1)*.05)), max(4,int((y2-y1)*.10))
    x1,y1,x2,y2 = max(0,x1-px),max(0,y1-py),min(w,x2+px),min(h,y2+py)
    crop = image[y1:y2, x1:x2]
    if crop.size == 0:
        raise HTTPException(status_code=422, detail="Empty plate crop.")
    plate, ocr_conf = _ocr_best(crop)
    return {
        "plate_number": plate,
        "detection_confidence": float(confs[idx]),
        "ocr_confidence": float(ocr_conf),
        "box": [x1,y1,x2,y2],
    }
