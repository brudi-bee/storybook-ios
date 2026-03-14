# Changelog

Alle relevanten Änderungen am Storybook-iOS-Projekt.

## [Unreleased]

### Added
- **2025-03-14**: HomeView Code Review Improvements - Vollständige Implementierung
  - **Accessibility**: Labels und Hints für alle interaktiven Elemente
    - Neue Geschichte Button mit Label und Hint
    - Alle Buttons mit beschreibenden Labels
    - Story Cards mit kombinierten Accessibility-Elementen
    - Button-Traits für tippbare Cards
  - **Haptic Feedback**: Taktiles Feedback bei Story-Auswahl
    - UISelectionFeedbackGenerator für Bibliotheks-Stories
    - UIImpactFeedbackGenerator für Featured Stories
  - **Alle anzeigen Button**: erscheint wenn >6 Stories in Bibliothek
    - Navigiert zu LibraryView
    - Gecapseltes Design mit Chevron
  - **Pull-to-Refresh**: Bibliothek aktualisierbar
    - Lädt Stories neu aus SwiftData
    - Mit Haptic Feedback
  - **Unified Card Styling**: Konsistente Card-Designs
    - CardStyle Enum mit Shared Constants
    - StoryCardStyle ViewModifier
    - Beide Card-Typen nutzen identische Shadows und Corner Radius

### Changed
- **2025-03-14**: FeaturedStories in SDAppStore extrahiert
  - `FeaturedStory` Modell in SDAppStore verschoben mit `defaultStories`
  - `@Published var featuredStories` in SDAppStore für zentrale Verwaltung
  - HomeView verwendet jetzt `store.featuredStories` statt lokalem Array

### Added
- **2025-03-12**: `APIService` neu implementiert
  - URLSession-basierter HTTP-Client mit Retry-Logik
  - Exponential Backoff mit 3 Versuchen und Jitter
  - `APIError` enum mit spezifischen Fehlerarten (network, decoding, server)
  - `fetchStory(from: URL)` Methode für HTTP und lokale JSON-Dateien (file://)
  - `GeneratedStory` Struct für API-Responses
  - Unterstützt Bundle-Ressourcen und direkte URL-Strings

## Format

- `Added` für neue Features
- `Changed` für Änderungen an bestehender Funktionalität
- `Deprecated` für Features, die entfernt werden
- `Removed` für entfernte Features
- `Fixed` für Bugfixes
- `Security` für Security-relevante Fixes
