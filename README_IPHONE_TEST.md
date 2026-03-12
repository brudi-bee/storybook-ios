# 📱 Storybook iOS - iPhone Test Anleitung

## ⚠️ Wichtig: Bauen auf dem MAC

Ich kann die App hier auf Linux **nicht bauen oder signieren**. Du musst sie auf deinem **Mac mit Xcode** kompilieren.

## Schnellstart (5 Minuten)

### 1. Projekt auf deinen Mac kopieren

```bash
# Auf deinem Mac Terminal:
cd ~/Documents  # oder wo du willst
git clone https://github.com/brudi-bee/storybook-ios.git
# ODER: ZIP vom Workspace kopieren
```

### 2. Xcode Project generieren

```bash
cd storybook-ios
bash scripts/setup-macos.sh
```

Das erstellt `Storybook.xcodeproj`.

### 3. In Xcode öffnen

```bash
open Storybook.xcodeproj
```

### 4. Auf iPhone deployen

1. **Device auswählen**: Oben in Xcode dein iPhone auswählen
2. **Signing**: Bei "Signing & Capabilities" dein Apple Account auswählen
3. **Build**: Cmd+R drücken
4. **Trust**: Auf dem iPhone unter Einstellungen → VPN & Gerätenanagement → dein Account vertrauen

## Funktionen zum Testen

### ✅ Kern-Features
- [ ] **Onboarding**: Erststart zeigt Tutorial
- [ ] **Kinderprofile**: Bis zu 2 Kinder anlegen (Name + Geschlecht)
- [ ] **Generator**: Genre/Setting/Moral wählen → Story erstellen
- [ ] **Reader**: Szenenweise lesen, Swipe zwischen Szenen
- [ ] **BGM**: Hintergrundmusik an/aus, Sleep Timer
- [ ] **Bibliothek**: Stories als Cards, Swipe-to-Delete, Favoriten

### ✅ Neu: Parental Controls
- [ ] **Elternbereich**: Limits für Geschichten/Tag
- [ ] **Content Filter**: Automatische Prüfung (Dummy)
- [ ] **Tageslimit**: Zähler ztellt sich täglich zurück

### ✅ SwiftData
- [ ] Daten bleiben nach App-Neustart erhalten
- [ ] Automatische Löschung alter Stories (wenn Limit erreicht)

## Bekannte Limitationen (MVP)

1. **KI-Generierung ist Mock**: Erstellt feste Template-Geschichten (kein echter AI-Call)
2. **Bilder sind Dummy**: Farbverläufe statt echter Illustrationen
3. **Kein echter BGM**: Stille (Audio-Framework vorhanden, aber keine MP3s)
4. **Keine Echtzeit-Synchronisation**: Alles lokal auf dem Gerät

## Backend (optional)

Für echte AI-Generierung brauchst du noch:
- Backend API (Cloudflare Worker oder eigener Server)
- OpenAI/Anthropic API-Key
- Siehe `docs/BACKEND_API_SPEC.md`

## Troubleshooting

### "Unable to find a destination"
→ iPhone per USB anschließen, in Xcode oben Device wählen

### "Signing issues"
→ Xcode → Signing & Capabilities → Team auswählen

### "Could not find module"
→ Xcode → Product → Clean Build Folder, dann neu bauen

## Files Übersicht

```
StorybookApp/
├── Models/
│   ├── SDChildProfile.swift      # SwiftData Models
│   └── ...
├── Views/
│   ├── OnboardingView.swift      # Tutorial-Intro
│   ├── ModernGeneratorView.swift # Polierte UI
│   ├── StoryCard.swift            # Bibliothek-Cards
│   ├── ParentalSettingsView.swift # Elternbereich
│   └── ...
├── SwiftData/
│   └── SDAppStore.swift          # Nach Persistence
└── ...

docs/
├── BACKEND_API_SPEC.md           # API für echte KI
└── ...
```

Fragen? Schreib mir 📲
