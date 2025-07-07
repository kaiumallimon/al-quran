# Al Quran Flutter App

A modern, cross-platform Quran application built with Flutter. This app provides a beautiful and accessible way to read, search, and listen to the Quran, with support for translations and user-friendly navigation.

## Features

- **Onboarding/Landing Pages**: Smooth introduction for first-time users.
- **Surah List & Navigation**: Browse and jump to any Surah with ease.
- **Read Quranic Text**: View Arabic text, English translation, and transliteration.
- **Search Functionality**: Quickly find Surahs or Ayahs by keyword.
- **Audio Playback**: Listen to Quranic recitations (using `assets_audio_player`).
- **Customizable Font Size**: Increase or decrease font size for better readability.
- **Sajda Alerts**: Get notified when a Sajda (prostration) verse appears.
- **Persistent User Preferences**: Remembers your last read position and settings (using `shared_preferences`).
- **Beautiful Typography**: Enhanced with Google Fonts.

## Screenshots

*(Add screenshots of your app here for better presentation!)*

## Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (>=3.3.0 <4.0.0)
- Dart

### Installation

1. **Clone the repository:**
   ```sh
   git clone https://github.com/yourusername/flutter-al-quran-app.git
   cd flutter-al-quran-app
   ```

2. **Install dependencies:**
   ```sh
   flutter pub get
   ```

3. **Run the app:**
   ```sh
   flutter run
   ```

### Assets

- All Quranic data, audio, and images are stored in the `assets/` directory.
- App icon and launcher images are configured for both Android and iOS.

## Project Structure

```
lib/
  data/           # Data services (Quran, search, etc.)
  presentation/   # UI: pages, widgets, providers
    pages/
      landing_pages/   # Onboarding/intro screens
      main_page/       # Main Quran reading and navigation
      search_page/     # Search interface
    widgets/           # Reusable UI components
    providers/         # State management
  services/        # Utility services (audio, session, etc.)
assets/            # Images, audio, and Quranic data
```

## Dependencies

- `provider` for state management
- `google_fonts` for typography
- `assets_audio_player` for audio playback
- `shared_preferences` for persistent storage
- `carousel_slider` for onboarding/landing pages
- `http` for network requests (if needed)
- `cupertino_icons` for iOS-style icons

See [`pubspec.yaml`](pubspec.yaml) for the full list.

## Contributing

Pull requests are welcome! For major changes, please open an issue first to discuss what you would like to change.

## License

[MIT](LICENSE) *(or specify your license here)*
