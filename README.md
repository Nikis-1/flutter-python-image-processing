# 📸 Flutter + Python Digital Image Processing App

A simple **full-stack image processing app** using:
- ✅ **Flutter Web** for the frontend
- ✅ **Python Flask** + **OpenCV** for the backend

Upload an image, select an operation (Edge Detection, Noise Removal, etc.), process it, and download the output — all in your browser!

---

## 🚀 Features

- 🗂️ Select from 6 basic image operations:
  - Histogram Equalization
  - Noise Removal
  - Thresholding
  - Edge Detection
  - Erosion
  - Dilation
- 📤 Upload an image from your device
- ⚙️ Processed by Python OpenCV on the backend
- 📥 Download the processed image

---

## 🧩 Tech Stack

| Layer    | Tool              |
|----------|-------------------|
| Frontend | Flutter Web       |
| Backend  | Python Flask      |
| CV Logic | OpenCV            |

---

## ⚡ How to Run

### 📦 1. Backend

```bash
cd python_backend
python -m venv venv

# Windows
venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Run Flask server
python app.py
```
### 2. Frontend (Flutter)
```bash
# From your project root
flutter pub get
flutter run -d chrome
```
✔️ Pick an operation
✔️ Upload an image
✔️ Click Process
✔️ Download your result!

### 📝 Author
Nikita Sanganeria

### 📜 License
This project is licensed under the MIT License — feel free to use and modify it!
