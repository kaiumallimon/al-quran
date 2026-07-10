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

## Feature 3: Audio Player — NOT STARTED

- Mini player
- Full player
- Background playback
- Reciter selection
- Offline audio cache

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

## Feature 7: Notifications — NOT STARTED

- Daily reminders
- Goal/streak reminders
- Smart scheduling

---

## Feature 8: Profile & Settings — NOT STARTED

- User profile
- Authentication (Firebase)
- Appearance, reading, audio settings
- Privacy & accessibility

---

## Firebase Integration — NOT STARTED

- Auth (anonymous, Google, Apple)
- Firestore sync
- Crashlytics
- Analytics (opt-in)
- FCM notifications

---

## Next Steps (Priority Order)

1. **Audio Player** — recitation playback, mini/full player
2. **Profile & Settings** — user preferences and Firebase auth
3. **Notifications** — reminders

---

## API Editions Used

| Purpose | Edition ID |
|---------|-----------|
| Arabic text | `quran-uthmani` |
| English translation | `en.sahih` |
| Bangla | `bn.bengali` |

Reference: `api.yaml` (alquran.cloud v1)

---

## Architecture Reminders

- UI → Provider → Repository → Datasource → API/Hive
- No build_runner / hive_generator — manual serialization only
- Cache before network, never block UI on refresh
- Provider is the only state management solution
