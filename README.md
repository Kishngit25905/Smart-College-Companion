#  Smart College Companion

A unified student productivity mobile application built with **Flutter** and **Dart**, designed to help engineering college students manage their academic life efficiently.

---

##  Features

| Feature | Description |
|---|---|
|  **Attendance Tracker** | Track subject-wise attendance with real-time percentage and skip prediction |
|  **Timetable Scheduler** | Organize your weekly class schedule day by day |
|  **Assignment Manager** | Never miss deadlines with color-coded urgency indicators |
|  **Marks Predictor** | Calculate external marks needed based on your internal scores |
|  **Notes & PDF Organizer** | Save text notes, import PDFs, and store resource links |
|  **Exam Countdown** | Countdown timer for upcoming exams with motivational indicators |
|  **CGPA Calculator** | Multi-semester GPA and CGPA calculator using VTU 10-point grading |
|  **AI Chatbot** | AI-powered academic assistant for instant doubt resolution |
|  **Login Screen** | Personalized profile setup with name displayed on home screen |

---

##  Tech Stack

- **Framework:** Flutter 3.41.7
- **Language:** Dart 3.11.5
- **AI API:** Groq API (llama-3.3-70b-versatile)
- **Local Storage:** SharedPreferences
- **Target Platform:** Android 5.0 (API 21) and above

---

##  Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  shared_preferences: ^2.2.2
  http: ^1.2.0
  file_picker: ^8.1.2
  open_filex: ^4.3.4
  provider: ^6.1.1
  intl: ^0.19.0
  flutter_local_notifications: ^17.0.0
  percent_indicator: ^4.2.3
  lottie: ^3.0.0
```

---

##  Getting Started

### Prerequisites

- Flutter SDK 3.0 or above → [Install Flutter](https://flutter.dev/docs/get-started/install)
- Android Studio or VS Code
- Android device or emulator

### Installation

**1. Clone the repository**
```bash
git clone https://github.com/Kishngit25905/Smart-College-Companion.git
cd Smart-College-Companion
```

**2. Install dependencies**
```bash
flutter pub get
```

**3. Add your API Key**

Open `lib/screens/chatbot_screen.dart` and replace:
```dart
static const String _apiKey = 'YOUR_GROQ_API_KEY_HERE';
```
with your actual Groq API key from [console.groq.com](https://console.groq.com)

**4. Run the app**
```bash
flutter run
```

---

##  Project Structure

```
lib/
├── main.dart                    # App entry point and theme
└── screens/
    ├── home_screen.dart         # Dashboard with 8-module grid
    ├── login_screen.dart        # Student profile setup
    ├── attendance_screen.dart   # Attendance tracker
    ├── timetable_screen.dart    # Weekly timetable
    ├── assignments_screen.dart  # Assignment manager
    ├── marks_screen.dart        # Marks predictor
    ├── notes_screen.dart        # Notes and PDF organizer
    ├── countdown_screen.dart    # Exam countdown
    ├── cgpa_screen.dart         # CGPA calculator
    └── chatbot_screen.dart      # AI chatbot
```

---

##  API Setup

This app uses the **Groq API** for the AI chatbot feature.

1. Go to [console.groq.com](https://console.groq.com)
2. Sign up for a free account
3. Click **API Keys** → **Create API Key**
4. Copy the key and paste it in `chatbot_screen.dart`

>  **Never push your API key to GitHub!** Keep it local only.

---

##  Performance

| Metric | Result |
|---|---|
| App Launch Time | ~1.5 seconds |
| Local Data Load | ~100ms |
| AI Chatbot Response | 2–4 seconds (5G) |
| APK Size | ~18 MB |
| UI Frame Rate | 58–60 fps |

---

##  Future Enhancements

- [ ] Firebase Cloud Database integration
- [ ] Push notifications for assignment deadlines
- [ ] iOS support
- [ ] Analytics dashboard with charts
- [ ] Export attendance and CGPA as PDF
- [ ] Offline AI chatbot

---

##  Developer

**KISHAN G**
- USN: 1NT23IS101
- Department: Information Science and Engineering
- College: Nitte Meenakshi Institute of Technology, Bengaluru
- Academic Year: 2025–2026

---

##  Project Info

- **Subject:** Hybrid Application Development (HAD)
- **Semester:** 6th Semester BE
- **Guide:** Mr. Hanumanthappa H, Assistant Professor, Dept. of ISE, NMIT

---

##  License

This project is built for academic purposes as part of the VTU curriculum.

---

> Built using Flutter
- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
