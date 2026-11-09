
from pathlib import Path
import json
from ultralytics import YOLO

BASE_DIR = Path(__file__).resolve().parent.parent

DATA_YAML = BASE_DIR / "dataset" / "data.yaml"
BEST_MODEL = (
    BASE_DIR / "model" / "runs" /
    "onion_grading" / "weights" / "best.pt"
)

OUTPUT_DIR = BASE_DIR / "model" / "evaluation"
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

model = YOLO(str(BEST_MODEL))

metrics = model.val(
    data=str(DATA_YAML),
    split="test",
    imgsz=640,
    conf=0.25,
    plots=True
)

precision = float(metrics.box.mp)
recall = float(metrics.box.mr)
map50 = float(metrics.box.map50)
map50_95 = float(metrics.box.map)

f1 = (2 * precision * recall) / (precision + recall + 1e-9)

results = {
    "model_name": "Onion IQ YOLOv8",
    "model_version": "1.0",
    "evaluation_dataset": "test",
    "precision": round(precision * 100, 2),
    "recall": round(recall * 100, 2),
    "f1_score": round(f1 * 100, 2),
    "map50": round(map50 * 100, 2),
    "map50_95": round(map50_95 * 100, 2)
}

# Save evaluation results
with open(OUTPUT_DIR / "metrics.json", "w") as file:
    json.dump(results, file, indent=4)

print("Evaluation metrics saved successfully!")
print(json.dumps(results, indent=4))
