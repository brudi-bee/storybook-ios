# Storybook iOS (MVP)

Kinder-Märchen App mit personalisierten Protagonisten (bis zu 2 Kinder), Mehrsprachigkeit und AI-Story-Generierung.

## MVP Scope
- Kinderprofile (Name + Geschlecht, bis zu 2)
- Story-Generator mit Genre/Setting/Moral/Länge/Sprache
- Einfache, sichere Geschichten (kindgerecht)
- Dummy-Bilder pro Szene
- Leise Hintergrundmusik (ohne Voice)
- Story-Bibliothek lokal gespeichert

## Projektstruktur
- `docs/` Produkt- und Implementierungsdoku
- `backend/prompts/` Prompt-Templates
- `backend/schemas/` JSON-Schema für Story-Ausgabe
- `scripts/` Setup-Skripte (macOS/Xcode)
- `StorybookApp/` App-Quellstruktur (SwiftUI Templates)

## Quick Start (Mac)
1. Xcode installieren (App Store)
2. Im Terminal:
   ```bash
   cd projects/storybook-ios
   bash scripts/setup-macos.sh
   ```
3. Projekt erzeugen:
   ```bash
   xcodegen generate
   open Storybook.xcodeproj
   ```

## Hinweise
- Diese Umgebung ist Linux-basiert, daher kann Xcode hier nicht gestartet werden.
- Ich habe alles vorbereitet, damit du es auf dem Mac direkt öffnen und starten kannst.
