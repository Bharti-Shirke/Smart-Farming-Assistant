# Smart Farming Assistant (Flutter + FastAPI) — core build

## Run on Windows
1. Install Flutter (flutter.dev), Android Studio + emulator, Python 3.10+.
2. Backend:
```
cd backend
python -m venv venv && venv\Scripts\activate
pip install -r requirements.txt
copy .env.example .env      (add GEMINI_API_KEY from aistudio.google.com, and JWT_SECRET)
python ml\train_crop.py     (put Kaggle Crop_recommendation.csv in backend\data first; otherwise SYNTHETIC demo data is used)
uvicorn app.main:app --reload --host 0.0.0.0
```
3. Disease model (optional, heavy): `pip install tensorflow`, download PlantVillage into `backend/data/plantvillage/<Class>/`, run `python ml\train_disease.py` from backend. Until then `/disease/predict` returns a clear "model not installed" message.
4. App: `cd app`, `flutter create .`, `flutter pub get`, `flutter run`. On a real phone set `baseUrl` in lib/main.dart to your PC's LAN IP. Add CAMERA permission to AndroidManifest.xml.
API docs: http://localhost:8000/docs

## What uses what
- ML: Random Forest crop recommendation; MobileNetV2 transfer learning (PlantVillage) for disease.
- Rule-based: irrigation, fertilizer (indicative rates; soil test advised), weather tips.
- API: Open-Meteo weather (no key; falls back to demo data).
- Generative AI: Gemini; question language detected from script (heuristic Hindi vs Marathi), answer in same language, profile-aware.
- DB: SQLite `users(email, pw, profile JSON)`.

## Not yet built
Voice mode (add `speech_to_text` + `flutter_tts`, send transcript to `/assistant/chat`), onboarding/profile/settings screens, irrigation/fertilizer/calendar/market/notification screens (irrigation, fertilizer, notifications endpoints exist; calendar and market have no data source), tests, push notifications. Replace fixed-salt PBKDF2 with bcrypt/argon2 before real deployment.
