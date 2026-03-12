import Foundation
import SwiftUI

@MainActor
final class AppStore: ObservableObject {
    @Published var children: [ChildProfile] = [] {
        didSet { persistence.saveChildren(children) }
    }
    @Published var stories: [Story] = [] {
        didSet { persistence.saveStories(stories) }
    }
    @Published var request = StoryRequest()

    @Published var isGenerating = false
    @Published var selectedStory: Story?

    let audioManager = AudioManager()

    private let generator: StoryGeneratorService
    private let persistence: PersistenceService

    init(
        generator: StoryGeneratorService = MockStoryGeneratorService(),
        persistence: PersistenceService = UserDefaultsPersistenceService()
    ) {
        self.generator = generator
        self.persistence = persistence
        self.children = persistence.loadChildren()
        self.stories = persistence.loadStories()
    }

    func upsertChild(index: Int, name: String, gender: ChildGender) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        if index < children.count {
            children[index].name = trimmed
            children[index].gender = gender
        } else if children.count < 2 {
            children.append(ChildProfile(name: trimmed, gender: gender))
        }
    }

    func removeSecondChildIfNeeded(enabled: Bool) {
        if !enabled, children.count > 1 {
            children = [children[0]]
        }
    }

    func generateStory() async {
        guard !children.isEmpty else { return }
        isGenerating = true
        defer { isGenerating = false }

        do {
            let story = try await generator.generateStory(request: request, children: children)
            stories.insert(story, at: 0)
            selectedStory = story
        } catch {
            print("Story generation failed: \(error)")
        }
    }
}
