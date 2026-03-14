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
    
    // Featured stories from app store
    @Published var featuredStories: [FeaturedStory] = FeaturedStory.defaultStories
    
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
            // Konvertiere SwiftData Profile zurück für Generator
            let childProfiles = children.map { SDChildProfile(name: $0.name, gender: $0.gender, order: $0.order) }
            let story = try await generator.generateStory(request: request, children: childProfiles)
            
            // Konvertiere zu SwiftData Story
            let sdStory = Story(
                title: story.title,
                language: story.language,
                genre: story.genre,
                setting: story.setting,
                moral: story.moral,
                scenes: story.scenes
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
            print("Story generation failed: \(error.localizedDescription ?? error.localizedDescription)")
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

// Compatibility struct for generator
struct SDChildProfile {
    let name: String
    let gender: ChildGender
    let order: Int
}

// Extension für Generator-Service
extension MockStoryGeneratorService {
    func generateStory(request: StoryRequest, children: [SDChildProfile]) async throws -> Story {
        // Convert to standard format
        let stdChildren = children.map { ChildProfile(name: $0.name, gender: $0.gender) }
        return try await generateStory(request: request, children: stdChildren)
    }
}