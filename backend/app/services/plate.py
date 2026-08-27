import re

def normalize_plate(text: str) -> str:
    return re.sub(r"[^A-Z0-9]", "", text.upper())

def plate_shape_score(text: str) -> float:
    # Soft heuristic, not a legal definition of Malaysian registration plates.
    text = normalize_plate(text)
    if re.fullmatch(r"[A-Z]{1,3}\d{1,4}[A-Z]{0,2}", text):
        return 2.0
    if 4 <= len(text) <= 12 and re.search(r"[A-Z]", text) and re.search(r"\d", text):
        return 0.5
    return -10.0
