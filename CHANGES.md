# Changelog

Alle relevanten Änderungen am Storybook-iOS-Projekt.

## [Unreleased]

### Added
- **2026-03-14**: Professional Children's Book Reader Implementation
  - **ProfessionalTheme.swift**: Complete design system with warm, cozy colors
    - Color constants (warm browns, cozy oranges, soft creams)
    - Typography with rounded, child-friendly fonts
    - Shadow and gradient styles
    - Button styles matching reference design
    - SceneIllustrationTheme enum for consistent scene styling
  - **ExampleStory.json**: 30-scene bedtime story "Die Traumkatze Klara"
    - Progressive narrative: Introduction → Conflict → Resolution → Happy End
    - Settings: Child's bedroom, Dream world, Moon, Stars, Clouds
    - Each scene: 1-2 sentences, simple language, bedtime story style
    - German language, Fantasy/Bedtime genre
    - Complete with image prompts and illustration themes
  - **SampleIllustrations.swift**: Gradient placeholders for all 30 scenes
    - Different colors/themes per scene
    - Character consistency through iconography
    - SceneIllustration model for structured data
  - **Redesigned ReaderView.swift**: Professional children's book reader UI
    - Full-screen illustration area (top 70%)
    - Text card at bottom (30%) with rounded corners and shadow
    - Left/Right navigation arrows (white, semi-transparent circles)
    - Page counter (e.g., "8/30") in top-left
    - Top bar with: Home button, Progress bar, Music button, Menu button
    - Warm, cozy color scheme (browns, oranges)
    - Smooth page transition animations (slide + fade)
    - Page indicator dots at bottom of text card
    - Accessibility labels for all interactive elements

### Changed
- **2026-03-14**: Updated Models.swift
  - Added `illustrationTheme` to StoryScene for consistent scene styling
  - Added `totalPages` computed property to Story
  - Added `ReadingProgress` struct for tracking reading state
  - Added `illustrationPrompt(for:)` helper method
  - Added `progressPercentage(for:)` helper method

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
