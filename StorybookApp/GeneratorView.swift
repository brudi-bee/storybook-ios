import SwiftUI

struct GeneratorView: View {
    @EnvironmentObject var store: SDAppStore

    var body: some View {
        NavigationStack {
            Form {
                Section("Story Einstellungen") {
                    Picker("Sprache", selection: $store.request.language) {
                        ForEach(StoryLanguage.allCases) { lang in
                            Text(lang.displayName).tag(lang)
                        }
                    }
                    .pickerStyle(.segmented)

                    Picker("Genre", selection: $store.request.genre) {
                        ForEach(StoryGenre.allCases) { genre in
                            Text(genre.displayName).tag(genre)
                        }
                    }

                    TextField("Setting (z. B. Sternenwald)", text: $store.request.setting)
                    TextField("Moral (z. B. Mut)", text: $store.request.moral)
                    Stepper("Szenen: \(store.request.sceneCount)", value: $store.request.sceneCount, in: 4...10)
                }

                Section {
                    if store.children.isEmpty {
                        Label("Bitte zuerst Kinderprofile anlegen", systemImage: "exclamationmark.triangle")
                            .foregroundStyle(.orange)
                    }

                    Button {
                        Task { await store.generateStory() }
                    } label: {
                        if store.isGenerating {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Neue Geschichte generieren")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(store.children.isEmpty || store.isGenerating)
                }
            }
            .navigationTitle("Märchen Generator")
            .navigationDestination(item: $store.selectedStory) { story in
                ReaderView(story: convertToDTO(story))
            }
        }
    }
    
    private func convertToDTO(_ story: Story) -> StoryDTO {
        return StoryDTO(
            id: story.id,
            title: story.title,
            language: story.language,
            genre: story.genre,
            setting: story.setting,
            moral: story.moral,
            children: [],
            scenes: story.scenes,
            createdAt: story.createdAt
        )
    }
}
