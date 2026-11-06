from pathlib import Path
from ultralytics import YOLO
import shutil

BASE_DIR = Path(__file__).resolve().parent.parent

DATA_YAML = BASE_DIR / "dataset" / "data.yaml"

model = YOLO("yolov8n.pt")

model.train(
    data=str(DATA_YAML),
    epochs=100,
    imgsz=640,
    batch=16,
    project=str(BASE_DIR / "runs"),
    name="onion_grading",
    exist_ok=True
)

BEST_MODEL = BASE_DIR / "runs" / "onion_grading" / "weights" / "best.pt"

MODEL_DIR = BASE_DIR / "model"
shutil.copy2(BEST_MODEL, MODEL_DIR / "best.pt")

print("Training completed successfully!")
