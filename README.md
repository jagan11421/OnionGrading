# 🧅 Onion IQ – AI-Based Onion Quality Assessment

**Onion IQ** is an AI-powered onion quality assessment application that uses computer vision and deep learning to identify onion quality grades from images. It integrates a YOLOv8 object detection model with a FastAPI backend and a Flutter frontend to provide an accessible onion inspection system.

The application aims to automate onion quality inspection by detecting different quality categories and providing prediction results through a mobile-friendly interface.

## ✨ Features

- **AI-Based Detection:** Uses YOLOv8 for onion quality detection.
- **Quality Classification:** Identifies Fresh, Medium, and Rotten onions.
- **Image Inspection:** Upload or capture onion images for analysis.
- **Real-Time API Processing:** Processes images through a FastAPI backend.
- **Model Performance Dashboard:** Displays model evaluation metrics.
- **Prediction Results:** Shows detected classes, confidence scores, and bounding boxes.
- **Cross-Platform Frontend:** Built using Flutter.

## 🛠️ Technology Stack

| Component | Technology |
|---|---|
| Frontend | Flutter, Dart |
| Backend | Python, FastAPI |
| Deep Learning | YOLOv8 |
| Model Training | Ultralytics |
| Image Processing | Pillow |
| API Communication | REST API |
| Version Control | Git, GitHub |

## 📁 Project Structure

```text
OnionGrading/
│
├── frontend/                 # Flutter application
│   ├── lib/
│   │   ├── screens/
│   │   ├── services/
│   │   ├── widgets/
│   │   └── main.dart
│   └── pubspec.yaml
│
├── backend/                  # FastAPI backend
│   └── main.py
│
├── model/                    # Model training and evaluation
│   ├── train.py
│   ├── evaluate.py
│   ├── best.pt
│   └── evaluation/
│       └── metrics.json
│
├── dataset/                  # YOLO dataset (not included in Git)
│   ├── train/
│   ├── valid/
│   ├── test/
│   └── data.yaml
│
├── venv/                     # Python virtual environment
│
├── .gitignore
└── README.md
```

## ⚙️ Installation and Setup

### 1. Clone the Repository

```bash
git clone https://github.com/jagan11421/OnionGrading.git
cd OnionGrading
```

### 2. Backend Setup

Create and activate a Python virtual environment.

**macOS / Linux:**

```bash
python3 -m venv venv
source venv/bin/activate
```

Install the required dependencies:

```bash
pip install fastapi "uvicorn[standard]" python-multipart pillow ultralytics
```

### 3. Configure the YOLOv8 Model

Place your trained model weights at:

```text
model/best.pt
```

The backend loads the trained model from this location.

If you store your model weights elsewhere, update `MODEL_PATH` in `backend/main.py`.

### 4. Start the FastAPI Backend

```bash
cd backend
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

Backend URL:

```text
http://127.0.0.1:8000
```

API documentation:

```text
http://127.0.0.1:8000/docs
```

## 📱 Flutter Frontend Setup

Open another terminal:

```bash
cd OnionGrading/frontend
```

Install Flutter dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

### API Configuration

Configure the backend URL in your Flutter API service.

```dart
static const String apiUrl = 'http://127.0.0.1:8000';
```

For Android Emulator, use:

```dart
static const String apiUrl = 'http://10.0.2.2:8000';
```

For a physical Android device, use your computer's local network IP address.

For production, configure your hosted backend's HTTPS URL.

## 🧠 Model Training

Onion IQ uses the YOLOv8 architecture for object detection.

### Dataset Configuration

The dataset follows the YOLO directory structure:

```text
dataset/
├── train/
│   ├── images/
│   └── labels/
│
├── valid/
│   ├── images/
│   └── labels/
│
├── test/
│   ├── images/
│   └── labels/
│
└── data.yaml
```

Example `data.yaml`:

```yaml
path: .
train: train/images
val: valid/images
test: test/images

names:
  0: Fresh
  1: Medium
  2: Rotten
```

### Train the Model

From the project root:

```bash
cd model
python3 train.py
```

The trained model weights are generated in the training output directory. Copy the best-performing weights to `model/best.pt` for backend inference if your training script saves them elsewhere.

## 📊 Model Evaluation

Evaluate the trained model using:

```bash
cd model
python3 evaluate.py
```

The evaluation process can generate:

- Precision
- Recall
- F1-Score
- mAP@50
- mAP@50-95
- Confusion Matrix
- Precision-Recall Curve

Evaluation metrics are saved in:

```text
model/evaluation/metrics.json
```

The FastAPI backend exposes the model performance data through:

```http
GET /model-metrics
```

## 🔌 API Endpoints

| Method | Endpoint | Description |
|---|---|---|
| GET | `/` | Check API status |
| POST | `/inspect` | Analyze an uploaded onion image |
| GET | `/model-metrics` | Retrieve model evaluation metrics |

Interactive API documentation is available at `/docs`.

## 🚀 Future Enhancements

- Improve detection accuracy with larger and more diverse datasets.
- Add detailed onion quality grading reports.
- Maintain inspection history.
- Generate downloadable quality assessment reports.
- Optimize inference speed for mobile devices.
- Deploy the application for wider accessibility.

## 👨‍💻 Author

**Jaganmohan Reddy**

- GitHub: [@jagan11421](https://github.com/jagan11421)

## 📄 License

This project is intended for educational and research purposes. A formal open-source license can be added when the project is ready for public distribution.

