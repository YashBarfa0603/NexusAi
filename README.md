<div align="center">

<img src="assets/screenshots/home.png" width="120" alt="Nexus AI Logo"/>

# 🤖 Nexus AI

**A modern cross-platform AI assistant built with Flutter, FastAPI, and Google's Gemini API.**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.100+-009688?logo=fastapi)](https://fastapi.tiangolo.com)
[![Gemini](https://img.shields.io/badge/Gemini-2.5_Flash-4285F4?logo=google)](https://ai.google.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Desktop-blue)](https://flutter.dev/multi-platform)

Nexus AI is an intelligent chatbot that enables users to interact with AI through **text, images, documents, and voice**. It combines a clean Flutter frontend with a scalable FastAPI backend to deliver fast, accurate, and multimodal AI interactions.

[Features](#-features) • [Screenshots](#-screenshots) • [Tech Stack](#️-tech-stack) • [Getting Started](#-getting-started) • [API Reference](#-api-endpoints) • [Contributing](#-contributing)

</div>

---

## ✨ Features

### 💬 AI Chat
Natural language conversations powered by Gemini 2.5 Flash — fast, accurate, and context-aware.

### 🖼️ Image Understanding
Upload images and receive detailed descriptions or answers based on visual content.

### 📄 Document Analysis
Upload PDF, DOCX, or TXT files. Get summaries, extracted information, and answers to document-related questions.

### 🎙️ Voice Support
Upload audio recordings to get AI-powered transcriptions and intelligent responses.

### 📱 Cross-Platform
Runs seamlessly across **Android**, **iOS**, **Web**, **Windows**, **macOS**, and **Linux**.

### ⚡ FastAPI Backend
RESTful APIs with a modular, easy-to-extend architecture.

### 🎨 Modern Flutter UI
Clean chat interface with message bubbles, typing indicators, attachment support, and responsive design.

---

## 📸 Screenshots

<div align="center">

| Home Screen | Introduction | Chat |
|:-----------:|:------------:|:----:|
| <img src="assets/screenshots/home.png" width="200" alt="Home Screen"/> | <img src="assets/screenshots/intro.png" width="200" alt="Introduction"/> | <img src="https://github.com/YashBarfa0603/NexusAi/blob/990ebf1a89b54f510518d6805dc1442af3363136/Chat.png" width="200" alt="Chat"/> |
| Empty state with prompt | AI introduces itself | Multi-turn conversation |

</div>

> **Note:** To add screenshots, place them in the `assets/screenshots/` folder and update the paths above.

---

## 🏗️ Project Structure

```
NexusAi/
│
├── ai_backend/                 # Python FastAPI backend
│   ├── app/
│   │   ├── config.py           # Environment & configuration
│   │   ├── models.py           # Pydantic data models
│   │   ├── prompts.py          # AI prompt templates
│   │   ├── routes.py           # API route definitions
│   │   ├── services.py         # Business logic & Gemini integration
│   │   └── __init__.py
│   ├── main.py                 # FastAPI entry point
│   ├── pyproject.toml
│   └── uv.lock
│
├── lib/                        # Flutter application
│   ├── model/                  # Data models
│   ├── screen/                 # UI screens
│   │   └── widgets/            # Reusable widgets
│   ├── services/               # API services
│   └── main.dart               # Flutter entry point
│
├── android/                    # Android platform files
├── ios/                        # iOS platform files
├── linux/                      # Linux platform files
├── macos/                      # macOS platform files
├── windows/                    # Windows platform files
├── web/                        # Web platform files
│
├── assets/
│   └── screenshots/            # App screenshots
│
├── pubspec.yaml
└── README.md
```

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| **Frontend** | Flutter · Dart · Material Design 3 |
| **Backend** | FastAPI · Python 3.11+ |
| **AI Engine** | Google Gemini 2.5 Flash |
| **AI SDK** | Google Generative AI SDK |

### Flutter Dependencies

| Package | Purpose |
|---------|---------|
| `http` | API communication |
| `file_picker` | Document & file selection |
| `image_picker` | Camera & gallery access |
| `record` | Audio recording |

### Python Dependencies

| Package | Purpose |
|---------|---------|
| `fastapi` | Web framework |
| `google-generativeai` | Gemini AI integration |
| `Pillow` | Image processing |
| `python-dotenv` | Environment variables |
| `pydantic` | Data validation |
| `uvicorn` | ASGI server |

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.x or later)
- [Python](https://www.python.org/downloads/) (3.11 or later)
- A [Google Gemini API Key](https://aistudio.google.com/apikey)

---

### 1. Clone the Repository

```bash
git clone https://github.com/YashBarfa0603/NexusAi.git
cd NexusAi
```

---

### 2. Backend Setup

```bash
# Navigate to the backend directory
cd ai_backend

# Create a virtual environment
python -m venv .venv

# Activate — Windows
.venv\Scripts\activate

# Activate — Linux / macOS
source .venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

Create a `.env` file in the `ai_backend/` directory:

```env
GEMINI_API_KEY=YOUR_API_KEY_HERE
```

Start the backend server:

```bash
uvicorn main:app --reload
```

| Resource | URL |
|----------|-----|
| Backend API | `http://localhost:8000` |
| Interactive Docs (Swagger) | `http://localhost:8000/docs` |
| Alternative Docs (ReDoc) | `http://localhost:8000/redoc` |

---

### 3. Flutter Setup

```bash
# From the project root
flutter pub get

# Run the application
flutter run
```

> **Tip:** To target a specific platform, use `flutter run -d chrome` (web), `flutter run -d windows`, etc.

---

## 📡 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/chat` | Text-based AI conversation |
| `POST` | `/image` | Analyze an uploaded image |
| `POST` | `/document` | Analyze an uploaded document (PDF, DOCX, TXT) |
| `POST` | `/voice` | Process and transcribe an audio file |

> Full interactive documentation is available at `http://localhost:8000/docs` when the backend is running.

---

## 🔮 Roadmap

- [ ] Conversation history & persistence
- [ ] Streaming AI responses
- [ ] Markdown & code syntax highlighting
- [ ] User authentication
- [ ] Chat export (PDF / TXT)
- [ ] Dark mode
- [ ] Cloud deployment (GCP / AWS)
- [ ] Response regeneration
- [ ] AI conversation memory
- [ ] Drag & drop file upload
- [ ] Speech-to-text streaming

---

## 🤝 Contributing

Contributions are welcome and appreciated!

1. **Fork** the repository
2. **Create** a feature branch
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Commit** your changes
   ```bash
   git commit -m "feat: add your feature description"
   ```
4. **Push** to your branch
   ```bash
   git push origin feature/your-feature-name
   ```
5. **Open** a Pull Request

Please follow [Conventional Commits](https://www.conventionalcommits.org/) for commit messages.

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Author

**Yash Barfa**

[![GitHub](https://img.shields.io/badge/GitHub-YashBarfa0603-181717?logo=github)](https://github.com/YashBarfa0603)

---

<div align="center">

If you found this project useful, please consider giving it a ⭐ **Star** on GitHub — it helps a lot!

</div>
