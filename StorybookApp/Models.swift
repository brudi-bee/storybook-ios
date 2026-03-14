import Foundation

// MARK: - Shared Types
// These types are used by both DTOs and SwiftData models

enum ChildGender: String, CaseIterable, Codable, Identifiable {
    case female
    case male
    case neutral

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .female: return "Mädchen"
        case .male: return "Junge"
        case .neutral: return "Neutral"
        }
    }
}

enum StoryLanguage: String, CaseIterable, Codable, Identifiable {
    case de
    case en

    var id: String { rawValue }
    var displayName: String { rawValue.uppercased() }
}

enum StoryGenre: String, CaseIterable, Codable, Identifiable {
    case adventure
    case friendship
    case fantasy
    case animals
    case bedtime

    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .adventure: return "Abenteuer"
        case .friendship: return "Freundschaft"
        case .fantasy: return "Fantasy"
        case .animals: return "Tiere"
        case .bedtime: return "Einschlafen"
        }
    }
}

// MARK: - StoryScene
// Shared struct used by both DTOs and SwiftData models (stored as JSON in SwiftData)
struct StoryScene: Identifiable, Codable {
    var id = UUID()
    var index: Int
    var text: String
    var imagePrompt: String
    var bgmMood: String
    var illustrationTheme: String? // Theme identifier for consistent scene styling
}

struct StoryRequest: Codable {
    var language: StoryLanguage = .de
    var genre: StoryGenre = .bedtime
    var setting: String = "Zauberwald"
    var moral: String = "Freundlichkeit"
    var sceneCount: Int = 6
    var ageRange: String = "3-6"
}

// MARK: - Data Transfer Objects (DTOs) for API
// These structs are used for API communication and JSON encoding/decoding.
// The main app models are the SwiftData models in Models/SDChildProfile.swift

struct ChildProfileDTO: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var gender: ChildGender
}

struct StoryDTO: Identifiable, Codable {
    var id = UUID()
    var title: String
    var language: StoryLanguage
    var genre: StoryGenre
    var setting: String
    var moral: String
    var children: [ChildProfileDTO]
    var scenes: [StoryScene]
    var createdAt = Date()
    
    // MARK: - Computed Properties
    var totalPages: Int {
        scenes.count
    }
    
    // MARK: - Reading Progress
    struct ReadingProgress: Codable {
        var storyId: UUID
        var currentPage: Int
        var lastReadAt: Date
        var isCompleted: Bool
        
        static func `default`(for storyId: UUID) -> ReadingProgress {
            ReadingProgress(
                storyId: storyId,
                currentPage: 0,
                lastReadAt: Date(),
                isCompleted: false
            )
        }
    }
}

// MARK: - StoryDTO Extension for Illustration
extension StoryDTO {
    func illustrationPrompt(for sceneIndex: Int) -> String {
        guard sceneIndex >= 0 && sceneIndex < scenes.count else { return "" }
        return scenes[sceneIndex].imagePrompt
    }
    
    func progressPercentage(for currentPage: Int) -> Double {
        guard totalPages > 0 else { return 0 }
        return Double(currentPage + 1) / Double(totalPages)
    }
}
