<p align="center">
  <img src="assets/logo.jpg" alt="Quran Companion" width="120" height="120">
</p>

<h1 align="center">Quran Companion</h1>

<p align="center">
  Read. Reflect. Grow.
  <br>
  A production-grade, offline-first Quran companion application.
</p>

---

## Overview

Quran Companion is a feature-rich, cross-platform application for reading, listening to, and studying the Quran. Built with Flutter and engineered with a clean architecture, it combines beautiful typography, immersive reading modes, intelligent audio playback, personal progress tracking, and cloud-synced data into a seamless spiritual companion.

## Features

### 📖 Reading Experience
- **Surah List** – Browse all 114 surahs with integrated search by name or number
- **Ayah-by-Ayah Display** – Arabic text alongside English translation, transliteration, and Bangla translation
- **Immersive Focus Mode** – Distraction-free reading with a full-screen layout
- **Sajda Alerts** – Visual indicators for prostration verses
- **Customizable Typography** – Adjustable Arabic font size (20–40), translation font size (12–24), and line height (1.4–2.4)
- **Auto-Resume** – Return to your last read position automatically
- **Keep Screen Awake** – Prevent screen dimming during reading

### 🎧 Audio Recitation
- **Multiple Reciters** – Choose from various renowned reciters
- **Full Playback Controls** – Play, pause, skip between ayahs, seek through audio
- **Adjustable Speed** – Playback from 0.75x to 2x
- **Repeat Modes** – Repeat single ayah, range, or entire surah
- **Sleep Timer** – Set audio to stop after 5–60 minutes
- **Background Playback** – Continue listening while using other apps
- **Offline Downloads** – Save surah audio for offline listening
- **Mini Player** – Persistent compact player in the bottom navigation bar

### 🔍 Search
- **Full-Text Search** – Search across Arabic, English, Bangla, and surah names
- **Search Suggestions** – Intelligent autocomplete and popular search terms
- **Recent Searches** – Quick access to previous queries
- **Instant Navigation** – Tap any result to jump directly to the verse

### 📊 Dashboard
- **Time-Based Greeting** – Personalized welcome message
- **Continue Reading** – Quick resume from where you left off
- **Daily Verse** – A featured verse each day with Arabic, translation, and transliteration
- **Reading Streak** – Track your current and longest reading streaks
- **Daily Goal** – Set and track your daily ayah reading target with animated progress
- **Today's Progress** – Overview of your reading activity for the day
- **Recently Read** – Quick access to recently viewed surahs
- **Quick Actions** – One-tap access to browse, search, bookmarks, and insights

### 📈 Insights & Analytics
- **Weekly / Monthly / Lifetime Summaries** – Total ayahs read, reading time, completed surahs
- **Reading Activity Chart** – Visual breakdown of your reading patterns
- **Personalized Recommendations** – Gentle suggestions based on your reading habits
- **Reading Insights** – Meaningful observations about your spiritual journey

### 🔖 Tracking Hub
- **Bookmarks** – Save and organize your favorite verses
- **Notes** – Attach personal notes to any verse
- **Reflections** – Journal your thoughts on specific ayahs
- **Reading Goals** – Set and manage personal reading targets
- **Reading History** – Complete log of your reading sessions

### ☁️ Cloud Sync
- **Cross-Device Backup** – Sync bookmarks, notes, reflections, and reading progress
- **Authentication** – Sign in with email, Google, Apple, or continue anonymously
- **Automatic Sync** – Seamless background synchronization when online

### 🔔 Notifications
- **In-App Notification Center** – Stay updated with reading reminders and achievements
- **Custom Reminders** – Schedule gentle reading reminders based on your preferences

### 🎨 Personalization
- **Themes** – System, Light, Dark, and true-black AMOLED mode
- **Accessibility** – Dynamic text, reduce motion, high contrast, RTL preview
- **Privacy Controls** – Opt-in analytics, crash reports, and cloud sync

## Architecture

```
lib/
├── core/           # Theme, constants, navigation, services, DI, shared widgets
├── data/           # Models, repositories, local & remote data sources
└── features/       # Feature modules (audio, auth, home, insights,
                    # notifications, profile, reading, search, shell,
                    # splash, tracking)
```

- **State Management** – Provider with ChangeNotifier
- **Local Storage** – Hive for offline persistence
- **Backend** – Firebase Auth + Cloud Firestore
- **Audio** – just_audio + audio_service with background support
- **Architecture** – Feature-first clean architecture with repository pattern
- **Dependency Injection** – Service locator pattern

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter (3.3+) / Dart |
| State | Provider |
| Local DB | Hive |
| Backend | Firebase Auth, Firestore |
| Audio | just_audio, audio_service |
| Fonts | Google Fonts |
| Connectivity | connectivity_plus |
| Navigation | Navigator 2.0 |

---

<p align="center">
  <strong>Quran Companion</strong> — Read. Reflect. Grow.
</p>
