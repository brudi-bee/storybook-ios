# Storybook AI Backend API Specification

## Endpoint
```
POST /v1/stories/generate
Content-Type: application/json
Authorization: Bearer {api-key}
```

## Request Body
```json
{
  "language": "de|en",
  "genre": "adventure|friendship|fantasy|animals|bedtime",
  "setting": "string (z.B. 'Zauberwald am See')",
  "moral": "string (z.B. 'Mut und Freundschaft')",
  "sceneCount": 6,
  "ageRange": "3-6|6-9|9-12",
  "children": [
    {
      "name": "string",
      "gender": "male|female|neutral",
      "order": 0
    }
  ]
}
```

## Response Body (200 OK)
```json
{
  "id": "uuid",
  "title": "string",
  "language": "de|en",
  "genre": "string",
  "setting": "string",
  "moral": "string",
  "createdAt": "ISO8601",
  "scenes": [
    {
      "index": 1,
      "text": "string (mit eingesetzten Namen)",
      "imagePrompt": "string (für spätere KI-Bilder)",
      "bgmMood": "calm|happy|tense|peaceful"
    }
  ],
  "contentSafety": {
    "rating": "safe|mild|review",
    "flags": []
  }
}
```

## Error Responses
- `400` Validation Error
- `429` Rate Limit (max X stories/day)
- `500` Generation failed

## Safety Features
1. **Content Filter**: Keine Gewalt, Angst, unangemessene Themen
2. **Age-appropriate**: Vokabular an ageRange angepasst
3. **Name injection**: Namen werden konsistent eingesetzt
4. **Length limits**: Szenenanzahl wird erzwungen

## Prompt Template (Backend)
```
Du bist ein preisgekrönter Kinderbuchautor. 
Schreibe eine GUTE-NACHT-GESCHICHTE für Kinder im Alter {ageRange}.

GENRE: {genre}
SETTING: {setting}
MORAL: {moral}
SPRACHE: {language}

HAUPTCHARAKTERE:
{child1.name} ({child1.gender})
{child2.name} ({child2.gender}) [optional]

REGELN:
- Genau {sceneCount} kurze Szenen
- Einfache, kurze Sätze
- Keine Angst, keine Gewalt
- Happy End
- Namen natürlich einbauen
- Für Vorlesen geeignet

OUTPUT als JSON:
{
  "title": "...",
  "scenes": [
    {"index":1, "text":"...", "imagePrompt":"...", "bgmMood":"calm"}
  ]
}
```
