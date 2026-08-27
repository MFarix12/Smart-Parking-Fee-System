# System flow

## Training
Dataset → Google Colab → YOLO training → validation → best.pt

## Permanent operation
Operator login → take vehicle photo → Flutter uploads image →
FastAPI authenticates operator → YOLO finds plate →
OCR reads characters → access rule check →
ENTRY creates active session / EXIT closes active session →
fee is calculated → PostgreSQL commits record →
response returns OPEN gate action → app displays result.

## Failure flow
If ANPR fails but the operator can read the plate:
Scan screen → Manual fallback → type plate → same entry/exit rules →
audit record says MANUAL_OPERATOR_ENTRY.

## Data
PostgreSQL:
- users
- registered_vehicles
- parking_sessions
- scan_events

Persistent volume:
- scan images
