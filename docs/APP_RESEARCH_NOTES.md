# App Research Notes (Storybook iOS)

## Beobachtungen aus Referenz-App („Kleine Märchen“)

Quelle: App Store Listing
- Personalisierung (Name + Geschlecht) ist ein zentraler Engagement-Treiber.
- Ruhige Melodien + starke Illustration werden als Kernnutzen kommuniziert.
- Mehrsprachigkeit ist wichtig (viele Sprachen unterstützt).
- Stories sind in kurze Szenen geschnitten (gut für mobile Lesbarkeit).
- Fokus ist klar auf Abendroutine/Schlafenszeit.

## Produktentscheidungen für unser MVP

1. **Personalisierung first**
   - bis zu 2 Kinderprofile
   - konsistente Namen/Geschlecht in jeder Story

2. **Lesefluss + Calm UX**
   - große Typografie, kurze Abschnitte
   - Hintergrundmusik optional und leise

3. **Mehrsprachige Story-Erzeugung**
   - DE/EN zum Start
   - Datenmodell offen für weitere Sprachen

4. **Szenenbasiertes Story-Modell**
   - jede Story in 6-10 Szenen
   - je Szene Text + Dummy-Bild + Mood

5. **Qualitätskontrolle für AI-Output**
   - JSON-Schema
   - inhaltliche Guardrails (kindgerecht, keine Gewalt)
   - Konsistenzprüfungen auf Namen/Geschlecht

## V2 Ausblick
- konsistente KI-Bilder über Character Sheet + Style Lock
- erweiterter Elternbereich (Lesedauer, Favoriten, Safe-Mode)
