# 🌌 Autism Support App — Flutter Graduation Project

> A galaxy-themed, fully accessible mobile app supporting children with autism,
> their parents, and therapists. Built with **Flutter + BLoC + Clean Architecture**,
> featuring animated cosmic backgrounds in both dark (deep space) and light (aurora) modes.

---

## ✨ What's New in This Version

| Feature | Details |
|---|---|
| 🌌 **Galaxy Theme** | Animated star field, drifting nebula clouds, cosmic gradients |
| 🌙 **Dark / Light Mode** | Full `ThemeBloc` with toggle — persisted via `shared_preferences` |
| 🎮 **Emotion Match Game** | Fully playable memory card game (Next Step #3 implemented!) |
| 💫 **Cosmic UI** | `GalaxyCard`, `GalaxyAppBar`, glowing nav bar, gradient icons |

---

## 📱 Screens

| Screen | Features |
|---|---|
| **Home** | Greeting, tip card, 6-feature grid with gradient icon cards |
| **Educational Games** | Category filter, progress bars, Emotion Match playable |
| **Chat (Buddy)** | Bot chat, animated typing dots, gradient message bubbles |
| **Text to Speech** | Phrase grid with TTS scaffold, favorites, speaking animation |
| **Community** | Search, tab filter, tag-color resource cards, like toggle |
| **Track Progress** | Parent/Doctor toggle, bar chart, daily logs, stat cards |

---

## 🏗️ Architecture

```
lib/
├── main.dart
├── core/
│   ├── bloc/
│   │   ├── navigation_bloc.dart      ← tab switching
│   │   ├── theme_bloc.dart           ← dark/light + persistence
│   ├── theme/
│   │   └── app_theme.dart            ← GalaxyColors, AppTextStyles, AppTheme
│   ├── widgets/
│   │   ├── galaxy_background.dart    ← animated stars + nebula painter
│   │   ├── galaxy_widgets.dart       ← GalaxyCard, GalaxyAppBar, ThemeToggle
│   │   └── main_scaffold.dart        ← shell with cosmic nav bar
│   └── router/app_router.dart
└── features/
    ├── home / games / chat / speak / community / progress
    │   ├── data/models/
    │   └── presentation/
    │       ├── bloc/  {event, state, bloc}
    │       └── pages/
    └── games/presentation/pages/
        └── emotion_match_game.dart   ← ✅ Next Step #3 done!
```

---

## 🚀 Getting Started

```bash
git clone <your-repo>
cd autism_app
flutter pub get
flutter run
```

> **Note on fonts**: The app uses `Nunito` from `google_fonts`. Either add
> `google_fonts: ^6.1.0` to your pubspec and update `AppTextStyles.fontFamily`,
> or download Nunito from [fonts.google.com](https://fonts.google.com/specimen/Nunito)
> and place TTF files in `assets/fonts/`.

---

## ✅ Next Steps Roadmap

### ✅ Already Done (This Version)
- [x] BLoC state management (all 6 features)
- [x] Galaxy dark/light theme with `ThemeBloc`
- [x] Animated star field + nebula background
- [x] Emotion Match mini-game (playable!)

---

### 🔊 Next Step 1 — Real Text-to-Speech (`flutter_tts`)

Already in `pubspec.yaml`. Wire it up in `SpeakBloc`:

```dart
// pubspec.yaml already has: flutter_tts: ^4.0.2

import 'package:flutter_tts/flutter_tts.dart';

class SpeakBloc extends Bloc<SpeakEvent, SpeakState> {
  final FlutterTts _tts = FlutterTts();

  SpeakBloc() : super(SpeakInitial()) {
    // ... existing handlers ...
    _configureTts();
  }

  Future<void> _configureTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5);   // slower for children
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.1);        // slightly higher, friendlier
  }

  Future<void> _onPhraseTriggered(SpeakPhraseTriggered event, Emitter<SpeakState> emit) async {
    if (state is SpeakLoaded) {
      emit((state as SpeakLoaded).copyWith(speakingPhraseId: event.phraseId));
      
      final phrase = (state as SpeakLoaded).phrases
          .firstWhere((p) => p.id == event.phraseId);
      
      await _tts.speak(phrase.text);  // ← real TTS here
      
      emit((state as SpeakLoaded).copyWith(clearSpeaking: true));
    }
  }
}
```

**Platform setup needed:**
- **Android**: Add `INTERNET` permission in `AndroidManifest.xml`
- **iOS**: Add `NSSpeechRecognitionUsageDescription` in `Info.plist`

---

### 🔥 Next Step 2 — Firebase Authentication + Firestore

Already in `pubspec.yaml`. Steps:

```bash
# 1. Install FlutterFire CLI
dart pub global activate flutterfire_cli

# 2. Configure (creates google-services.json + GoogleService-Info.plist)
flutterfire configure

# 3. Initialize in main.dart
```

```dart
// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const AutismApp());
}
```

**Auth Bloc** (new feature to create):

```dart
// features/auth/presentation/bloc/auth_bloc.dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthBloc() : super(AuthInitial()) {
    on<AuthLoginRequested>(_onLogin);
    on<AuthRegisterRequested>(_onRegister);
    on<AuthLogoutRequested>(_onLogout);
    on<AuthCheckRequested>(_onCheck);
  }

  Future<void> _onLogin(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _auth.signInWithEmailAndPassword(
        email: event.email, password: event.password,
      );
      emit(AuthAuthenticated());
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Login failed'));
    }
  }
}
```

**Firestore data structure:**
```
users/
  {uid}/
    profile: { parentName, childName, createdAt }
    sessions/
      {sessionId}: { date, score, activity, duration }
    progress/
      weekly: { mon: 0.6, tue: 0.75, ... }
```

---

### 🔔 Next Step 4 — Push Notifications (Firebase Messaging)

Already in `pubspec.yaml` (`firebase_messaging: ^14.7.10`).

```dart
// In main.dart, after Firebase.initializeApp():
final messaging = FirebaseMessaging.instance;

await messaging.requestPermission(
  alert: true, badge: true, sound: true,
);

// Handle foreground messages
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  // Show in-app snackbar or notification
  showNotificationBanner(message.notification?.title ?? '');
});

// Get FCM token for server-side targeting
final token = await messaging.getToken();
// Save token to Firestore: users/{uid}/fcmToken = token
```

**Daily reminder notification** (server-side via Cloud Functions):
```javascript
// functions/index.js
exports.sendDailyReminder = functions.pubsub
  .schedule('0 8 * * *')  // 8 AM daily
  .onRun(async () => {
    // Query all user FCM tokens from Firestore
    // Send: "Time for Sarah's daily practice! 🌟"
  });
```

---

### 💾 Next Step 5 — Offline SQLite

Already in `pubspec.yaml` (`sqflite: ^2.3.0`).

```dart
// core/data/local/database_helper.dart
class DatabaseHelper {
  static Database? _db;

  static Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'autism_app.db');
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE sessions (
        id TEXT PRIMARY KEY, date TEXT, score INTEGER,
        activity TEXT, duration INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE phrases (
        id TEXT PRIMARY KEY, text TEXT, emoji TEXT,
        category TEXT, isFavorite INTEGER DEFAULT 0
      )
    ''');
  }

  // CRUD operations
  static Future<void> insertSession(Map<String, dynamic> session) async {
    final db = await database;
    await db.insert('sessions', session, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Map<String, dynamic>>> getSessions() async {
    final db = await database;
    return db.query('sessions', orderBy: 'date DESC', limit: 30);
  }
}
```

**Sync strategy:**
```dart
// Repository pattern: try Firestore first, fall back to SQLite
class SessionRepository {
  Future<List<Session>> getSessions() async {
    try {
      final online = await _firestore.collection('sessions').get();
      // Cache to SQLite
      for (final doc in online.docs) {
        await DatabaseHelper.insertSession(doc.data());
      }
      return online.docs.map((d) => Session.fromMap(d.data())).toList();
    } catch (_) {
      // Offline fallback
      final local = await DatabaseHelper.getSessions();
      return local.map(Session.fromMap).toList();
    }
  }
}
```

---

### 🎮 More Mini-Games (Next Step 3 continued)

The `EmotionMatchGame` is done. Here are the next two to build:

**Word Builder** (`/games/word_builder_game.dart`):
```dart
// Drag letter tiles to form words
// Show picture → drag letters → spell it
// Use flutter_tts to pronounce the word when correct
```

**Social Stories** (`/games/social_stories_game.dart`):
```dart
// Show story panel by panel (images + text)
// Multiple choice: "What should they do next?"
// Narrated by Buddy bot via TTS
```

---

## 📦 All Dependencies

```yaml
flutter_bloc: ^8.1.3       # BLoC state management
go_router: ^12.0.0         # Navigation
google_fonts: ^6.1.0       # Nunito font
flutter_tts: ^4.0.2        # Text to speech (Step 1)
firebase_core: ^2.24.2     # Firebase (Step 2)
firebase_auth: ^4.15.3     # Authentication (Step 2)
cloud_firestore: ^4.13.6   # Database (Step 2)
firebase_messaging: ^14.7.10 # Push notifs (Step 4)
sqflite: ^2.3.0            # Offline SQLite (Step 5)
shared_preferences: ^2.2.2 # Theme persistence
lottie: ^3.0.0             # Celebration animations
```

---

## 🎨 Galaxy Design System

```dart
// Colors
GalaxyColors.nebulaPurple  // #7C3AED - primary
GalaxyColors.cosmicBlue    // #3B82F6 - secondary
GalaxyColors.auroraGreen   // #10B981 - success
GalaxyColors.solarGold     // #F59E0B - star/awards
GalaxyColors.stardustPink  // #EC4899 - favorites/love
GalaxyColors.supernovaRed  // #EF4444 - errors/alerts

// Theme-aware helpers
GalaxyColors.bg(isDark)         // background
GalaxyColors.surface(isDark)    // card surface
GalaxyColors.textPrimary(isDark)// main text

// Widgets
GalaxyCard(glowing: true, child: ...)  // card with glow
GalaxyAppBar(title: 'Page')            // appbar with back + theme toggle
GalaxyBackground(isDark: isDark, ...)  // animated star background
```

---

## 🎓 Graduation Tips

- **Demo tip**: Show dark mode → toggle → light mode transition live
- **Explain ThemeBloc**: The toggle persists to `shared_preferences`, restores on app restart
- **Explain GalaxyBackground**: Custom `CustomPainter` with two animation controllers — `_twinkle` (4s) for star flicker and `_drift` (20s) for nebula cloud movement
- **Emotion Match**: Fully playable. Show it as proof of concept for the game engine pattern
