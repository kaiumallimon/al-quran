# Implementation Memory

Track of what has been implemented and what remains. Updated after each feature.

---

## Project Reset (2026-07-11)

- Removed legacy code (`lib/presentation/`, `lib/services/`, `lib/data/` old files)
- Updated `pubspec.yaml` with production dependencies (Hive, Provider, http, google_fonts, etc.)
- Removed old dependencies (carousel_slider, assets_audio_player, shared_preferences)

---

## Foundation / Core Architecture — DONE

| Area | Status | Notes |
|------|--------|-------|
| Design tokens (colors, spacing, typography, theme) | Done | Light + dark themes |
| Exceptions & logging | Done | `AppException`, `NetworkException`, `ApiException`, etc. |
| API constants | Done | alquran.cloud base URL and edition IDs |
| Hive constants | Done | Box names for all data types |
| Service locator (DI) | Done | Central dependency registration |
| Shared widgets | Done | AppCard, SectionHeader, SkeletonLoader, EmptyState, ErrorState |
| Data models | Done | Surah, Ayah, Edition, ReadingProgress, Dashboard, DailyVerse, etc. |
| Quran API client | Done | Typed HTTP client with error handling |
| Remote datasource | Done | Surah list, ayahs, random ayah, multi-edition ayah |
| Hive local datasource | Done | Manual serialization, all boxes |
| Quran repository | Done | Cache-first with background refresh |
| Dashboard repository | Done | getDashboard, continue reading, daily verse, streaks, goals |
| Reading repository | Done | getSurah, downloadSurah, preferences, scroll position |
| Search repository | Done | Local + remote search, history, suggestions |
| Tracking repository | Done | Bookmarks, notes, reflections, goals, milestones, history |
| Insights repository | Done | Habit insights, summaries, gentle recommendations |
| Notification repository | Done | In-app reminders, smart scheduling, preferences |
| App shell | Done | Bottom nav: Home, Read, Search, Profile placeholder |
| Main entry point | Done | Hive init, DI, theme |

---

## Feature 1: Home Dashboard — DONE

| Component | Status | Notes |
|-----------|--------|-------|
| DashboardProvider | Done | Loading, loaded, error states |
| Greeting | Done | Time-based greeting |
| Continue Reading card | Done | Progress bar, resume action, empty state |
| Daily Goal card | Done | Animated progress bar |
| Today's Progress card | Done | Minutes, pages, ayahs, sessions |
| Reading Streak card | Done | Current + longest streak |
| Daily Verse card | Done | Arabic, English, Bangla, share, bookmark placeholder |
| Recently Read section | Done | Horizontal scroll of recent surahs |
| Quick Actions | Done | Surahs, Search, Bookmarks, Settings (nav placeholders) |
| Pull-to-refresh | Done | Background refresh |
| Skeleton loading | Done | On first load |
| Offline cache-first | Done | Dashboard loads from Hive immediately |
| Responsive layout | Done | Max width constraint on large screens |

---

## Feature 2: Reading Screen — DONE

| Component | Status | Notes |
|-----------|--------|-------|
| ReadingRepository | Done | getSurah, downloadSurah, save/restore progress, preferences, scroll position |
| ReadingProvider | Done | Surah list, reading state, preferences, highlight, scroll restore |
| SurahListPage | Done | Search, pull-to-refresh, 114 surahs, skeleton loading |
| ReadingScreenPage | Done | ListView.builder for performance, scroll restore, progress tracking |
| SurahHeader | Done | Arabic name, bismillah (except Surah 9) |
| ReadingControlsBar | Done | Font size, translation toggle, reading mode, offline save |
| AyahCard | Done | Arabic, English, Bangla, sajda indicator, highlight |
| VerseActionsSheet | Done | Bookmark, favorite, copy, share, note, reflection, play, repeat |
| ReadingModeSheet | Done | Normal, focus, hide translations, Arabic only, translation only |
| ReadingBottomBar | Done | Audio placeholder for next feature |
| Navigation wired | Done | Shell Read tab, home continue/recent reading, quick actions |
| Offline cache-first | Done | Surah with translations cached in Hive |
| Scroll position restore | Done | Per-surah ayah position saved and restored |

---

## Feature 3: Audio Player — DONE

| Component | Status | Notes |
|-----------|--------|-------|
| ReciterModel / AudioTrackModel / AudioPreferencesModel | Done | Manual serialization, repeat modes |
| AudioRemoteDataSource | Done | Surah & ayah audio from alquran.cloud |
| AudioLocalDataSource | Done | Hive metadata + file cache on disk |
| AudioRepository | Done | play, pause, seek, reciter, download, cache-first URLs |
| QuranAudioHandler | Done | just_audio + audio_service background playback |
| AudioProvider | Done | Loading, playing, paused, error; speed, repeat, sleep timer |
| MiniAudioPlayer | Done | Above bottom nav in app shell |
| FullAudioPlayerSheet | Done | Reciter, progress, speed, repeat, sleep timer, download |
| ReciterSelectionSheet | Done | 6 popular reciters, syncs with reading prefs |
| Reading integration | Done | Bottom bar, verse actions, ayah highlight sync |
| Offline audio cache | Done | Download surah audio, clear cache in settings |
| Android background | Done | Foreground service + notification controls |

---

## Feature 4: Search — DONE

| Component | Status | Notes |
|-----------|--------|-------|
| SearchRepository | Done | searchLocal, searchRemote, merge, recent, suggestions |
| SearchProvider | Done | 300ms debounce, cache-first, remote background merge |
| SearchPage | Done | Search bar, idle/loading/empty/error states |
| RecentSearchesSection | Done | Chips with clear history |
| SearchSuggestionsSection | Done | Prefix match from recent, surahs, popular terms |
| SearchResultTile | Done | Arabic, English, reference, match highlighting |
| HighlightedText | Done | Query term highlight in results |
| Hive search history | Done | Last 10 searches persisted |
| Local cache search | Done | Surah names + cached ayahs (Arabic, English, Bangla) |
| Remote API search | Done | English + Bangla via alquran.cloud |
| Navigation wired | Done | Search tab, home quick action, tap result → reading screen |
| AppShellProvider | Done | Programmatic tab switching |

---

## Feature 5: Personal Tracking — DONE

| Component | Status | Notes |
|-----------|--------|-------|
| TrackingRepository | Done | Bookmarks, favorites, notes, reflections, goals, history, milestones |
| TrackingLocalDataSource | Done | Hive boxes for all user-generated data |
| TrackingProvider | Done | CRUD, auto-save notes/reflections, search/filter |
| TrackingHubPage | Done | Tabbed hub: Bookmarks, Notes, Reflections, Goals, History |
| BookmarksTab | Done | Folders, search, delete, open verse |
| NotesTab | Done | Search, pin, auto-save editor |
| ReflectionsTab | Done | Calendar-style list, auto-save editor |
| GoalsTab | Done | Daily/weekly/monthly/custom, multiple units, progress bars |
| HistoryTab | Done | Sessions grouped by date, milestones display |
| Verse actions wired | Done | Bookmark, favorite, note, reflection from reading screen |
| Home bookmarks action | Done | Opens tracking hub |
| Goal auto-update | Done | Ayah progress increments active goals while reading |
| Milestones | Done | First ayah, bookmark, note, reflection, streak thresholds |
| Offline-first | Done | All data stored locally in Hive |

---

## Feature 6: Insights & Recommendations — DONE

| Component | Status | Notes |
|-----------|--------|-------|
| InsightModel / RecommendationModel / ReadingSummaryModel | Done | Manual serialization, category & action enums |
| JuzHelper | Done | Page-based juz progress for insights |
| InsightsRepository | Done | Local pattern analysis, summaries, recommendations |
| InsightsProvider | Done | Loading, loaded, error states |
| InsightsPage | Done | Recommendations, weekly/monthly/lifetime summaries, activity chart |
| InsightCard / RecommendationCard | Done | Reusable insight & recommendation tiles |
| ReadingSummaryCard | Done | Period stats display |
| ReadingActivityChart | Done | Weekly bar chart from daily activity |
| InsightsPreviewSection | Done | Home dashboard preview with top recommendation |
| InsightsNavigation | Done | Full page + recommendation tap actions |
| Home integration | Done | Preview section, pull-to-refresh, Insights quick action |
| Offline-first | Done | All insights generated locally from Hive sessions |

---

## Feature 7: Notifications — DONE

| Component | Status | Notes |
|-----------|--------|-------|
| AppNotificationModel / NotificationPreferencesModel | Done | In-app only, manual serialization |
| NotificationLocalDataSource | Done | Hive box for notifications + preferences |
| NotificationRepository | Done | Smart scheduling, deduplication, local generation |
| NotificationProvider | Done | Load, sync, read/dismiss, preferences |
| NotificationsPage | Done | In-app notification center with pull-to-refresh |
| NotificationTile | Done | Swipe to dismiss, unread indicator |
| NotificationSettingsSheet | Done | Schedule presets, smart scheduling, type toggles |
| NotificationNavigation | Done | Tap actions to reading, goals, milestones |
| Home badge | Done | Unread count on bell icon |
| App lifecycle sync | Done | Refresh on app resume via AppShell observer |
| Offline-first | Done | No FCM — all reminders generated and stored locally |

---

## Feature 8: Profile & Settings — DONE

| Component | Status | Notes |
|-----------|--------|-------|
| UserProfileModel / AppSettingsModel | Done | Local profile, theme, privacy, accessibility |
| ProfileLocalDataSource | Done | Hive boxes for profile + settings |
| ProfileRepository | Done | Profile CRUD, stats aggregation, auth stubs |
| SettingsRepository | Done | Persist app settings offline |
| ProfileProvider | Done | Profile, stats, sign-in/out stubs |
| SettingsProvider | Done | Theme, reading, privacy, accessibility toggles |
| ProfilePage | Done | Avatar, stats grid, account section, goals link |
| SettingsPage | Done | Appearance, reading, audio, notifications, storage, privacy, accessibility, about, developer |
| AMOLED theme | Done | AppTheme.amoled + theme mode selector |
| Auth stubs | Done | Anonymous, Google, Apple UI — Firebase sync pending |
| App shell wired | Done | Profile tab replaces placeholder |
| Offline-first | Done | All settings persist in Hive automatically |

---

## Firebase Integration — NOT STARTED

- Auth (anonymous, Google, Apple)
- Firestore sync
- Crashlytics
- Analytics (opt-in)
- FCM push notifications (in-app notifications done locally)

---

## Next Steps (Priority Order)

1. **Firebase Integration** — Auth, Firestore sync, Crashlytics, Analytics, FCM push

---

## Dependencies Added (Feature 3)

| Package | Purpose |
|---------|---------|
| just_audio | Audio playback engine |
| audio_service | Background playback + lock screen controls |
| rxdart | Combined playback streams |

---

## API Editions Used

| Purpose | Edition ID |
|---------|-----------|
| Arabic text | `quran-uthmani` |
| English translation | `en.sahih` |
| Bangla | `bn.bengali` |
| Audio (default reciter) | `ar.alafasy` |

Reference: `api.yaml` (alquran.cloud v1)

---

## Architecture Reminders

- UI → Provider → Repository → Datasource → API/Hive
- No build_runner / hive_generator — manual serialization only
- Cache before network, never block UI on refresh
- Provider is the only state management solution
