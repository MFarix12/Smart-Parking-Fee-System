from app.services.plate import normalize_plate, plate_shape_score

def test_normalize():
    assert normalize_plate(" jab 1234 ") == "JAB1234"

def test_shape():
    assert plate_shape_score("JAB1234") > 0
