import Foundation

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

struct ChildProfile: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var gender: ChildGender
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

struct StoryRequest: Codable {
    var language: StoryLanguage = .de
    var genre: StoryGenre = .bedtime
    var setting: String = "Zauberwald"
    var moral: String = "Freundlichkeit"
    var sceneCount: Int = 6
    var ageRange: String = "3-6"
}

struct StoryScene: Identifiable, Codable {
    var id = UUID()
    var index: Int
    var text: String
    var imagePrompt: String
    var bgmMood: String
}

struct Story: Identifiable, Codable {
    var id = UUID()
    var title: String
    var language: StoryLanguage
    var genre: StoryGenre
    var setting: String
    var moral: String
    var children: [ChildProfile]
    var scenes: [StoryScene]
    var createdAt = Date()
}
