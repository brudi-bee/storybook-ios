# Changelog

Alle relevanten Änderungen am Storybook-iOS-Projekt.

## [Unreleased]

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
