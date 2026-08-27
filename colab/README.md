# Colab flow

1. Open `ANPR_Training_Google_Colab.ipynb` in Google Colab.
2. Runtime → Change runtime type → GPU.
3. Run install/GPU cells.
4. Upload your YOLO-format plate dataset ZIP.
5. Check image/label counts.
6. Train for the baseline 80 epochs.
7. Validate.
8. Upload a real car photo and inspect the detected plate box.
9. Download `best.pt`.
10. Copy it into `backend/models/best.pt`.
11. Restart your permanent backend.

Colab is training only. The permanent API/database is Docker + PostgreSQL.
