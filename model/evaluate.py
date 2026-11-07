from pathlib import Path
from ultralytics import YOLO

BASE_DIR = Path(__file__).resolve().parent.parent

DATA_YAML = BASE_DIR / "dataset" / "data.yaml"

# BEST_MODEL = (
#     BASE_DIR / "model" / "runs" /
#     "onion_grading" / "weights" / "best.pt"
# )

model = YOLO("best.pt")

metrics = model.val(
    data=str(DATA_YAML),
    split="test",
    imgsz=640,
    conf=0.25
)

precision = metrics.box.mp
recall = metrics.box.mr
map50 = metrics.box.map50
map50_95 = metrics.box.map

f1 = (2 * precision * recall) / (precision + recall + 1e-9)

# Detection-based accuracy (Jaccard-style)
tp = metrics.box.nt_per_class.sum() if hasattr(metrics.box, "nt_per_class") else 0

# Use confusion matrix for aggregate detection counts instead
cm = metrics.confusion_matrix
matrix = cm.matrix

# Exclude background row/column
tp_count = sum(matrix[i][i] for i in range(min(matrix.shape)))
fp_count = sum(matrix[:, i].sum() - matrix[i][i] for i in range(matrix.shape[1] - 1))
fn_count = sum(matrix[i, :].sum() - matrix[i][i] for i in range(matrix.shape[0] - 1))

accuracy = tp_count / (tp_count + fp_count + fn_count + 1e-9)

print("\n===== Onion IQ Evaluation =====")
print(f"Accuracy (detection-based): {accuracy * 100:.2f}%")
print(f"Precision: {precision * 100:.2f}%")
print(f"Recall: {recall * 100:.2f}%")
print(f"F1 Score: {f1 * 100:.2f}%")
print(f"mAP50: {map50 * 100:.2f}%")
print(f"mAP50-95: {map50_95 * 100:.2f}%")