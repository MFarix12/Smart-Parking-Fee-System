from app.services.fee import calculate_fee_cents

def test_grace():
    assert calculate_fee_cents(15) == 0

def test_first_hour():
    assert calculate_fee_cents(16) == 200
    assert calculate_fee_cents(60) == 200

def test_second_hour():
    assert calculate_fee_cents(61) == 300
