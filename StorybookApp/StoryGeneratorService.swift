import Foundation

protocol StoryGeneratorService {
    func generateStory(request: StoryRequest, children: [ChildProfile]) async throws -> Story
}

struct MockStoryGeneratorService: StoryGeneratorService {
    func generateStory(request: StoryRequest, children: [ChildProfile]) async throws -> Story {
        try await Task.sleep(nanoseconds: 400_000_000)

        let c1 = children.first?.name ?? "Luna"
        let c2 = children.dropFirst().first?.name

        let baseLinesDE = [
            "Eines Abends entdeckte \(c1) im \(request.setting) ein leuchtendes Blatt.",
            "Das Blatt zeigte einen ruhigen Weg, der nur mit Mut und Freundlichkeit sichtbar wurde.",
            "An einer kleinen Brücke half \(c1) einem müden Igel und lernte, dass kleine Taten Großes bewirken.",
            "Hinter den Bäumen erklang eine sanfte Melodie und die Sterne wurden ganz nah.",
            "\(c1) erinnerte sich an die Moral: \(request.moral), und alle Probleme wurden leichter.",
            "Mit einem warmen Gefühl im Herzen kehrte \(c1) nach Hause zurück und schlief friedlich ein."
        ]

        let baseLinesEN = [
            "One evening, \(c1) found a glowing leaf in the \(request.setting).",
            "The leaf revealed a calm path that appeared only with courage and kindness.",
            "At a tiny bridge, \(c1) helped a tired hedgehog and learned that small acts matter.",
            "Behind the trees, a soft melody played and the stars felt close.",
            "\(c1) remembered the moral: \(request.moral), and every challenge became lighter.",
            "With a warm heart, \(c1) returned home and fell asleep peacefully."
        ]

        let lines = request.language == .de ? baseLinesDE : baseLinesEN
        let scoped = Array(lines.prefix(max(4, request.sceneCount)))

        let resolved = scoped.enumerated().map { idx, text in
            StoryScene(
                index: idx + 1,
                text: injectSecondChild(in: text, secondName: c2),
                imagePrompt: "dummy image scene \(idx + 1), \(request.genre.rawValue), \(request.setting)",
                bgmMood: "calm"
            )
        }

        return Story(
            title: request.language == .de ? "\(c1)s Gute-Nacht-Märchen" : "\(c1)'s Bedtime Tale",
            language: request.language,
            genre: request.genre,
            setting: request.setting,
            moral: request.moral,
            children: children,
            scenes: resolved
        )
    }

    private func injectSecondChild(in text: String, secondName: String?) -> String {
        guard let secondName, !secondName.isEmpty else { return text }
        if text.contains(" und ") { return text }
        return text.replacingOccurrences(of: ".", with: " und \(secondName) lächelte dabei.", options: [], range: text.range(of: "."))
    }
}
