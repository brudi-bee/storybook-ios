# AI Story Generator Flow

## Ziel
Aus einem kompakten Formular automatisch qualitativ hochwertige, kindgerechte Stories erzeugen.

## Formularfelder (App)
- Sprache (DE/EN)
- Genre
- Setting
- Moral
- Länge (Szenenanzahl)
- Altersbereich
- Kind 1 (Name + Geschlecht)
- Optional Kind 2 (Name + Geschlecht)

## Pipeline
1. **Input sammeln** (StoryRequest + ChildProfiles)
2. **Prompt-Template füllen** (`backend/prompts/story_prompt_template.md`)
3. **LLM-Output als JSON** (Schema-konform)
4. **JSON-Schema validieren** (`backend/schemas/story.schema.json`)
5. **Guardrails prüfen**
   - keine Gewalt/Horror
   - konsistente Namen/Geschlechter
   - kurze, einfache Sätze
6. **Story speichern**
7. **Reader anzeigen** (Dummy-Bilder + BGM)

## Nächster Schritt (v1.1)
- Server/Edge Function für AI-Generierung
- Retry + Self-healing bei JSON-Fehler
- Qualitätsrating (auto) vor Freigabe
