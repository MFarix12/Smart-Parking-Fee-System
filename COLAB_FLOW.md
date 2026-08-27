# Google Colab step-by-step

1. Prepare a YOLO dataset ZIP containing:
   - data.yaml
   - images/train
   - images/val
   - labels/train
   - labels/val

2. In Google Colab:
   Runtime → Change runtime type → GPU.

3. Upload:
   colab/ANPR_Training_Google_Colab.ipynb

4. Run the notebook from top to bottom.

5. Upload your dataset ZIP when asked.

6. Confirm train/val image and label counts are sensible.

7. Train the detector.

8. Check validation output and test a real car image.

9. Download:
   best.pt

10. Put it into:
    backend/models/best.pt

11. On the permanent server:
    docker compose restart backend

12. Verify:
    GET /health
    should show anpr_model_installed = true

13. Test in Swagger:
    POST /api/v1/auth/token
    POST /api/v1/parking/scan

14. Connect Flutter using your permanent HTTPS API URL.
