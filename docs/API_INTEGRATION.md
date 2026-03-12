# AI API Integration (next step)

Aktuell nutzt die App einen `MockStoryGeneratorService`.

## Bereits vorbereitet
- `AIAPIStoryGeneratorService.swift` vorhanden
- erwartet Endpoint, der `Story` JSON zurückgibt
- Payload:
  - `request` (StoryRequest)
  - `children` ([ChildProfile])

## Empfohlene Architektur
- App -> eigener Backend Endpoint (nicht direkt zu LLM Provider)
- Backend übernimmt:
  1. Prompt-Template füllen
  2. LLM call
  3. JSON-Validierung gegen Schema
  4. Safety/Quality checks
  5. Rückgabe an App

## Vorteile
- API-Keys bleiben serverseitig
- bessere Qualitätssicherung
- zentral steuerbare Prompt-Versionen
- sauberes Monitoring/Retry
