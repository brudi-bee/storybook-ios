import Foundation
import SwiftUI
import SwiftData

// MARK: - Featured Story Model
struct FeaturedStory: Identifiable, Sendable {
    let id: UUID
    let title: String
    let subtitle: String
    let genre: StoryGenre
    let color: Color
    let gradient: [Color]
    let image: String
    
    static let defaultStories: [FeaturedStory] = [
        FeaturedStory(
            id: UUID(),
            title: "Luna und der Sternenwald",
            subtitle: "Ein magisches Abenteuer",
            genre: .fantasy,
            color: .purple,
            gradient: [.purple, .pink],
            image: "sparkles"
        ),
        FeaturedStory(
            id: UUID(),
            title: "Max und die Mutprobe",
            subtitle: "Wenn Angst zu Freundschaft wird",
            genre: .adventure,
            color: .orange,
            gradient: [.orange, .red],
            image: "flame"
        ),
        FeaturedStory(
            id: UUID(),
            title: "Die Freundschaftsinsel",
            subtitle: "Zusammen sind wir stark",
            genre: .friendship,
            color: .green,
            gradient: [.green, .teal],
            image: "leaf"
        )
    ]
}

@MainActor
final class SDAppStore: ObservableObject {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    
    @Published var children: [ChildProfile] = []
    @Published var stories: [Story] = []
    @Published var request = StoryRequest()
    @Published var settings: AppSettings?
    
    // Featured stories shown on Home (derived from library)
    @Published var featuredStories: [FeaturedStory] = []
    
    @Published var isGenerating = false
    @Published var selectedStory: Story?
    @Published var lastGenerationError: String?
    @Published var isRetrying: Bool = false
    
    // MARK: - Avatar Generation
    @Published var avatarGenerationStatus: AvatarGenerationStatus = .notStarted
    @Published var isGeneratingAvatar = false
    
    let audioManager = AudioManager()
    
    private let generator: StoryGeneratorService
    private let apiService: APIService
    private var avatarService: AvatarGenerationService?
    
    init(generator: StoryGeneratorService? = nil) {
        // APIService mit Retry-Config initialisieren
        self.apiService = APIService(
            retryConfig: RetryConfig(
                maxRetries: 3,
                baseDelay: 1.0,
                maxDelay: 30.0,
                backoffMultiplier: 2.0
            )
        )
        
        // StoryGenerator wählen: Backend wenn verfügbar, sonst Mock
        self.generator = generator ?? SDAppStore.createGenerator(apiService: self.apiService)
        
        // SwiftData Container Setup
        do {
            let schema = Schema([
                ChildProfile.self,
                Story.self,
                AppSettings.self
            ])
            let config = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false
            )
            self.modelContainer = try ModelContainer(for: schema, configurations: [config])
            self.modelContext = ModelContext(modelContainer)
            
            // Initialize avatar service
            self.avatarService = createAvatarService()
            
            // Initial Load
            loadChildren()
            loadStories()
            loadOrCreateSettings()
            ensureInitialLibraryStories()
            refreshFeaturedFromLibrary()
            
        } catch {
            fatalError("Failed to initialize SwiftData: \(error)")
        }
    }
    
    // MARK: - Avatar Service
    private func createAvatarService() -> AvatarGenerationService {
        guard let settings = settings else {
            return MockAvatarService()
        }
        return AvatarServiceFactory.createService(useRealGeneration: settings.useRealAvatarGeneration)
    }
    
    func refreshAvatarService() {
        self.avatarService = createAvatarService()
    }
    
    // MARK: - Avatar Generation
    func generateAvatar(for child: ChildProfile, configuration: AvatarConfiguration) async {
        guard let service = avatarService else {
            avatarGenerationStatus = .failed(error: "Avatar service not available")
            return
        }
        
        isGeneratingAvatar = true
        avatarGenerationStatus = .generating(step: "Erstelle Avatar...")
        
        do {
            let gender = GenderSelection.from(child.gender)
            let result = try await service.generateAvatar(
                for: configuration,
                name: child.name,
                gender: gender
            )
            
            child.setAvatarImage(result.imageData)
            child.updateAvatarConfiguration(configuration)
            
            // Generate character sheet if enabled
            if settings?.autoGenerateCharacterSheet ?? false {
                avatarGenerationStatus = .generating(step: "Erstelle Charakter-Referenz...")
                let sheetResult = try await service.generateCharacterSheet(
                    for: configuration,
                    name: child.name,
                    gender: gender
                )
                
                let sheet = CharacterSheet(
                    frontView: sheetResult.frontView,
                    sideView: sheetResult.sideView,
                    backView: sheetResult.backView
                )
                child.setCharacterSheet(sheet)
            }
            
            saveContext()
            loadChildren()
            
            avatarGenerationStatus = .completed
            isGeneratingAvatar = false
            
        } catch let error as AvatarGenerationError {
            avatarGenerationStatus = .failed(error: error.localizedDescription ?? "Unknown error")
            isGeneratingAvatar = false
        } catch {
            avatarGenerationStatus = .failed(error: error.localizedDescription)
            isGeneratingAvatar = false
        }
    }
    
    func generateSceneImages(for story: Story, character: ChildProfile) async {
        guard let service = avatarService,
              let characterRef = character.characterSheet?.frontView ?? character.avatarImageData else {
            return
        }
        
        let config = character.avatarConfiguration
        
        for scene in story.scenes {
            do {
                let result = try await service.generateSceneImage(
                    scene: scene,
                    characterReference: characterRef,
                    configuration: config
                )
                
                story.setSceneImage(result.imageData, forSceneIndex: scene.index)
            } catch {
                print("Failed to generate scene \(scene.index): \(error)")
            }
        }
        
        saveContext()
    }
    
    // MARK: - Children
    func loadChildren() {
        let descriptor = FetchDescriptor<ChildProfile>(
            sortBy: [SortDescriptor(\.order)]
        )
        children = (try? modelContext.fetch(descriptor)) ?? []
    }
    
    func upsertChild(index: Int, name: String, gender: ChildGender) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        if index < children.count {
            children[index].name = trimmed
            children[index].genderRaw = gender.rawValue
        } else if children.count < 2 {
            let newChild = ChildProfile(name: trimmed, gender: gender, order: index)
            modelContext.insert(newChild)
            children.append(newChild)
        }
        
        saveContext()
        ensureInitialLibraryStories()
        refreshFeaturedFromLibrary()
    }

    @discardableResult
    func createEmptyChild() -> ChildProfile? {
        guard children.count < 2 else { return nil }
        let child = ChildProfile(name: "", gender: .neutral, order: children.count)
        modelContext.insert(child)
        saveContext()
        loadChildren()
        return child
    }

    func persistChanges() {
        saveContext()
        loadChildren()
        loadStories()
        ensureInitialLibraryStories()
        refreshFeaturedFromLibrary()
    }
    
    func removeSecondChildIfNeeded(enabled: Bool) {
        if !enabled, children.count > 1 {
            modelContext.delete(children[1])
            loadChildren()
        }
    }
    
    func updateChildAvatar(_ child: ChildProfile, configuration: AvatarConfiguration) {
        child.updateAvatarConfiguration(configuration)
        saveContext()
    }
    
    // MARK: - Stories
    func loadStories() {
        let descriptor = FetchDescriptor<Story>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        stories = (try? modelContext.fetch(descriptor)) ?? []
        refreshFeaturedFromLibrary()
    }
    
    func addStory(_ story: Story) {
        modelContext.insert(story)
        
        // Max stories limit
        if stories.count >= (settings?.maxStoriesToKeep ?? 50) {
            let excess = stories.count - (settings?.maxStoriesToKeep ?? 50) + 1
            let oldest = stories.suffix(excess)
            for story in oldest {
                modelContext.delete(story)
            }
        }
        
        settings?.incrementStoryCount()
        saveContext()
        loadStories()
    }
    
    func deleteStory(_ story: Story) {
        modelContext.delete(story)
        saveContext()
        loadStories()
    }

    func refreshFeaturedFromLibrary() {
        featuredStories = stories.prefix(3).map { story in
            FeaturedStory(
                id: story.id,
                title: story.title,
                subtitle: story.setting,
                genre: story.genre,
                color: colorForGenre(story.genre),
                gradient: gradientForGenre(story.genre),
                image: iconForGenre(story.genre)
            )
        }
    }

    private func ensureInitialLibraryStories() {
        guard stories.isEmpty, let child = children.first, !child.name.isEmpty else { return }

        let baseName = child.name
        let pronoun = child.gender == .female ? "sie" : child.gender == .male ? "er" : "sie"

        let story1 = Story(
            title: "Die Karte der 7 Monde",
            language: .de,
            genre: .adventure,
            setting: "Tal der Sternenbrücken",
            moral: "Mut wächst, wenn man anderen hilft.",
            scenes: buildScenes(title: "Die Karte der 7 Monde", hero: baseName, pronoun: pronoun, mood: "adventure")
        )

        let story2 = Story(
            title: "Das Geheimnis vom Leuchtturm",
            language: .de,
            genre: .adventure,
            setting: "Klippenhafen",
            moral: "Gemeinsam findet man den Weg.",
            scenes: buildScenes(title: "Das Geheimnis vom Leuchtturm", hero: baseName, pronoun: pronoun, mood: "calm")
        )

        let story3 = Story(
            title: "Die Brücke aus Morgenlicht",
            language: .de,
            genre: .adventure,
            setting: "Wolkenpass",
            moral: "Vertrauen macht stark.",
            scenes: buildScenes(title: "Die Brücke aus Morgenlicht", hero: baseName, pronoun: pronoun, mood: "peaceful")
        )

        let story4 = Story(
            title: "Das Rätsel der Himmelsuhr",
            language: .de,
            genre: .adventure,
            setting: "Turm der Wolkeninseln",
            moral: "Geduld bringt Klarheit.",
            scenes: buildScenes(title: "Das Rätsel der Himmelsuhr", hero: baseName, pronoun: pronoun, mood: "calm")
        )

        let story5 = Story(
            title: "Der Weg durch den Funkenwald",
            language: .de,
            genre: .adventure,
            setting: "Funkenwald",
            moral: "Mut und Freundlichkeit öffnen Türen.",
            scenes: buildScenes(title: "Der Weg durch den Funkenwald", hero: baseName, pronoun: pronoun, mood: "adventure")
        )

        modelContext.insert(story1)
        modelContext.insert(story2)
        modelContext.insert(story3)
        modelContext.insert(story4)
        modelContext.insert(story5)
        saveContext()
        loadStories()
    }

    private func buildScenes(title: String, hero: String, pronoun: String, mood: String) -> [StoryScene] {
        let lines = [
            "Am Abend entdeckte \(hero) eine alte Spur im Sand.",
            "Die Spur führte zu einem Tor aus Licht.",
            "Leise trat \(hero) hindurch und hielt die Luft an.",
            "Hinter dem Tor wartete eine Karte mit drei Zeichen.",
            "Ein Windstoß drehte die Karte Richtung Norden.",
            "\(hero) folgte dem Weg über eine schmale Brücke.",
            "Unter der Brücke funkelte ein Fluss wie Glas.",
            "Ein kleiner Vogel zeigte \(hero) den nächsten Pfad.",
            "Am Hügel stand ein steinerner Kompass.",
            "Der Kompass sprang erst an, als \(hero) freundlich sprach.",
            "Dann öffnete sich eine verborgene Tür im Felsen.",
            "Drinnen lag ein Schlüssel, warm wie Sonnenlicht.",
            "Mit dem Schlüssel begann ein leises Summen im Tal.",
            "\(hero) merkte: Der Weg wurde heller.",
            "Am Ende erschien eine Brücke aus Morgenlicht.",
            "\(hero) machte einen Schritt, dann noch einen.",
            "Auf der anderen Seite wartete ein ruhiger Garten.",
            "Dort lag eine kleine Laterne mit Sternenmuster.",
            "Als \(hero) sie anhob, klang eine sanfte Melodie.",
            "Die Melodie führte zu einem alten Leuchtturm.",
            "Der Turm war dunkel, doch \(hero) blieb mutig.",
            "Oben im Turm fand \(hero) ein Zahnrad aus Silber.",
            "Mit dem Zahnrad setzte sich ein Uhrwerk in Bewegung.",
            "Licht wanderte über Dächer, Wälder und Felder.",
            "Die Nacht wirkte plötzlich freundlich und weich.",
            "\(hero) lächelte, weil \(pronoun) den Weg gefunden hatte.",
            "Ein Fuchs nickte dankbar vom Rand des Pfads.",
            "Gemeinsam gingen sie zurück zum Dorf.",
            "Am Fenster stellte \(hero) die Laterne ab.",
            "Mit einem warmen Gefühl schlief \(hero) friedlich ein."
        ]

        return lines.enumerated().map { idx, line in
            StoryScene(
                index: idx + 1,
                text: line,
                imagePrompt: "children's book \(title) scene \(idx + 1), hero \(hero), cozy adventure",
                bgmMood: mood,
                illustrationTheme: "adventure"
            )
        }
    }

    private func colorForGenre(_ genre: StoryGenre) -> Color {
        switch genre {
        case .adventure: return .orange
        case .friendship: return .green
        case .fantasy: return .purple
        case .animals: return .brown
        case .bedtime: return .blue
        }
    }

    private func gradientForGenre(_ genre: StoryGenre) -> [Color] {
        switch genre {
        case .adventure: return [.orange, .red]
        case .friendship: return [.green, .teal]
        case .fantasy: return [.purple, .pink]
        case .animals: return [.brown, .orange]
        case .bedtime: return [.blue, .indigo]
        }
    }

    private func iconForGenre(_ genre: StoryGenre) -> String {
        switch genre {
        case .adventure: return "map.fill"
        case .friendship: return "heart.fill"
        case .fantasy: return "sparkles"
        case .animals: return "pawprint.fill"
        case .bedtime: return "moon.fill"
        }
    }
    
    func toggleFavorite(_ story: Story) {
        story.isFavorite.toggle()
        saveContext()
    }
    
    func setCharacterReference(for story: Story, imageData: Data) {
        story.setCharacterReference(imageData)
        saveContext()
    }
    
    // MARK: - Settings
    func loadOrCreateSettings() {
        let descriptor = FetchDescriptor<AppSettings>()
        if let existing = try? modelContext.fetch(descriptor).first {
            settings = existing
        } else {
            let newSettings = AppSettings()
            modelContext.insert(newSettings)
            settings = newSettings
            saveContext()
        }
    }
    
    func updateSettings(_ updates: (AppSettings) -> Void) {
        guard let settings = settings else { return }
        updates(settings)
        saveContext()
        
        // Refresh avatar service if setting changed
        refreshAvatarService()
    }
    
    // MARK: - Generator Factory
    private static func createGenerator(apiService: APIService) -> StoryGeneratorService {
        // Versuche Backend-Generator zu erstellen, sonst Fallback auf Mock
        do {
            return try BackendStoryService(apiService: apiService)
        } catch {
            print("Backend Service nicht verfügbar, verwende Mock: \(error)")
            return MockStoryGeneratorService()
        }
    }
    
    // MARK: - Generation
    func canGenerateStory() -> Bool {
        guard !children.isEmpty else { return false }
        return settings?.canGenerateNewStory() ?? true
    }
    
    func generateStory() async {
        guard !children.isEmpty, canGenerateStory() else { return }
        isGenerating = true
        lastGenerationError = nil
        defer { isGenerating = false }
        
        do {
            // Konvertiere SwiftData Profile zu DTOs für Generator
            let childProfiles = children.map { ChildProfileDTO(name: $0.name, gender: $0.gender) }
            let storyDTO = try await generator.generateStory(request: request, children: childProfiles)
            
            // Konvertiere StoryDTO zu SwiftData Story
            let scenes = storyDTO.scenes.map { sceneDTO in
                StoryScene(
                    index: sceneDTO.index,
                    text: sceneDTO.text,
                    imagePrompt: sceneDTO.imagePrompt,
                    bgmMood: sceneDTO.bgmMood,
                    illustrationTheme: sceneDTO.illustrationTheme
                )
            }
            
            let sdStory = Story(
                title: storyDTO.title,
                language: storyDTO.language,
                genre: storyDTO.genre,
                setting: storyDTO.setting,
                moral: storyDTO.moral,
                scenes: scenes
            )
            
            // Set character reference if available
            if let firstChild = children.first,
               let avatarData = firstChild.avatarImageData {
                sdStory.setCharacterReference(avatarData)
            }
            
            addStory(sdStory)
            selectedStory = sdStory
            lastGenerationError = nil
            
            // Auto-generate scene images if enabled
            if settings?.useRealAvatarGeneration ?? false,
               let firstChild = children.first {
                await generateSceneImages(for: sdStory, character: firstChild)
            }
            
        } catch let error as APIError {
            lastGenerationError = error.localizedDescription
            print("Story generation failed: \(error.localizedDescription)")
        } catch {
            lastGenerationError = error.localizedDescription
            print("Story generation failed: \(error)")
        }
    }
    
    // MARK: - Health Check
    func checkBackendHealth() async -> Bool {
        await apiService.healthCheck(url: URL(string: "https://api.storybook-ai.de/v1/health")!)
    }
    
    // MARK: - Helper
    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            print("SwiftData save error: \(error)")
        }
    }
}
