# Implementation Plan - Saudi News Flutter App

Migrating the "Saudi News" portal from React to Flutter using **Feature-based Clean Architecture**. The app will eventually integrate with a Firestore stream (fed by a Twitter-to-AI Cloud Function).

## User Review Required

> [!IMPORTANT]
> **Architecture Style:** We will use the **Feature-based Clean Architecture** folder structure: `features/[feature_name]/{data, domain, presentation}`.
> **State Management:** I propose using **Bloc/Cubit** for the stream-based data (Firestore) as it handles stream subscriptions very cleanly.
> **Theming:** The UI will strictly follow the React design: Saudi Green (`#006C35`), RTL support, and Dark Mode transitions.

## Proposed Changes

### Core & Config

#### [NEW] [AppTheme](file:///C:/Users/tiger/StudioProjects/saudi_news/lib/core/theme/app_theme.dart)
Define the ColorScheme for Light and Dark modes.
- Light: Background `#F8F9FA`, Primary `#006C35`.
- Dark: Background `#0D1117`, Card `#161B22`.

#### [NEW] [Core Widgets](file:///C:/Users/tiger/StudioProjects/saudi_news/lib/core/widgets/)
- `AppHeader`: The custom Saudi-themed top bar.
- `BreakingTicker`: Animated marquee for breaking news.
- `AppBottomNav`: The 5-tab navigation bar.
- `CategoryPills`: Horizontal scrollable filters.

---

### Features

#### [NEW] News Feature
- **Domain:** `Article` entity.
- **Data:** `NewsRepository` (fetching from Firestore `Stream`).
- **Presentation:** `HomeScreen`, `NewsListScreen`, `TechScreen`.
- **UI:** Replicating the `NewsCard` and `SmallNewsCard` layouts with `CachedNetworkImage`.

#### [NEW] Directory Feature
- **Domain:** `DirectoryItem` entity.
- **Presentation:** `DirectoryScreen` (Search + Categories), `DirectoryDetailScreen`.
- **Logic:** Launching URLs for Phone, WhatsApp, and Google Maps.

#### [NEW] Sports Feature
- **Domain:** `MatchResult`, `LeagueTable` entities.
- **Presentation:** `SportsScreen` with the 3-tab toggle (Matches, Standings, News).

#### [NEW] Jobs Feature
- **Domain:** `JobPosting` entity.
- **Presentation:** `JobsScreen` with salary and location badges.

#### [NEW] Prayer Feature
- **Presentation:** `PrayerView`.
- **UI:** The Prayer Grid and the **Qibla Compass** (implemented using a `CustomPainter` or rotated `SvgPicture`).

#### [NEW] More Menu & Settings
- **Presentation:** `MoreMenuScreen`, `SettingsScreen`, `FavoritesScreen`.
- **Settings:** Dark mode toggle using `ThemeMode` switching.

---

### Integration Logic (Cloud & Data Flow)
1. **Source:** Twitter accounts via `TwitterAPI.io`.
2. **Middleware:** Firebase Cloud Function triggers AI classification.
3. **Storage:** Firestore document with `category`, `source`, `timestamp`.
4. **App Layer:** `FirebaseFirestore.instance.collection('news').snapshots()` maps to the `NewsBloc`.

## Verification Plan

### Automated Tests
- Unit tests for `NewsRepository` mapping Firestore JSON to `Article` entities.
- Widget tests for the `QiblaCompass` rotation logic.

### Manual Verification
- Verify RTL layout consistency on both Android and iOS emulators.
- Test Dark Mode toggle responsiveness.
- Verify "Call" and "Maps" buttons in the Directory feature.
