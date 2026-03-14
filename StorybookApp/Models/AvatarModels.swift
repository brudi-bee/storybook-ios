import Foundation
import SwiftUI
import SwiftData
import UIKit

// MARK: - Avatar Style Enum
enum AvatarStyle: String, CaseIterable, Codable, Identifiable {
    case animalRabbit
    case animalBear
    case animalFox
    case cartoon
    case realistic
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .animalRabbit: return "Häschen"
        case .animalBear: return "Bärchen"
        case .animalFox: return "Füchschen"
        case .cartoon: return "Cartoon"
        case .realistic: return "Realistisch"
        }
    }
    
    var icon: String {
        switch self {
        case .animalRabbit: return "hare.fill"
        case .animalBear: return "pawprint.fill"
        case .animalFox: return "leaf.fill"
        case .cartoon: return "face.smiling.fill"
        case .realistic: return "person.fill"
        }
    }
    
    var description: String {
        switch self {
        case .animalRabbit: return "Ein süßes Häschen als Avatar"
        case .animalBear: return "Ein kuscheliges Bärchen als Avatar"
        case .animalFox: return "Ein schlaues Füchschen als Avatar"
        case .cartoon: return "Ein lustiger Cartoon-Charakter"
        case .realistic: return "Ein realistischer Charakter"
        }
    }
}

// MARK: - Hair Color Enum
enum HairColor: String, CaseIterable, Codable, Identifiable {
    case blonde
    case brown
    case black
    case red
    case other
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .blonde: return "Blond"
        case .brown: return "Braun"
        case .black: return "Schwarz"
        case .red: return "Rot"
        case .other: return "Andere"
        }
    }
    
    var color: Color {
        switch self {
        case .blonde: return Color(red: 0.95, green: 0.85, blue: 0.5)
        case .brown: return Color(red: 0.4, green: 0.25, blue: 0.1)
        case .black: return Color(red: 0.1, green: 0.1, blue: 0.1)
        case .red: return Color(red: 0.8, green: 0.2, blue: 0.1)
        case .other: return Color.gray
        }
    }
    
    var promptDescription: String {
        switch self {
        case .blonde: return "blonde hair"
        case .brown: return "brown hair"
        case .black: return "black hair"
        case .red: return "red hair"
        case .other: return "colorful hair"
        }
    }
}

// MARK: - Skin Tone Enum
enum SkinTone: String, CaseIterable, Codable, Identifiable {
    case light
    case medium
    case dark
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .light: return "Hell"
        case .medium: return "Mittel"
        case .dark: return "Dunkel"
        }
    }
    
    var color: Color {
        switch self {
        case .light: return Color(red: 1.0, green: 0.9, blue: 0.8)
        case .medium: return Color(red: 0.8, green: 0.6, blue: 0.4)
        case .dark: return Color(red: 0.4, green: 0.25, blue: 0.15)
        }
    }
    
    var promptDescription: String {
        switch self {
        case .light: return "light skin tone"
        case .medium: return "medium skin tone"
        case .dark: return "dark skin tone"
        }
    }
}

// MARK: - Eye Color Enum
enum EyeColor: String, CaseIterable, Codable, Identifiable {
    case blue
    case green
    case brown
    case hazel
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .blue: return "Blau"
        case .green: return "Grün"
        case .brown: return "Braun"
        case .hazel: return "Haselnuss"
        }
    }
    
    var color: Color {
        switch self {
        case .blue: return Color(red: 0.3, green: 0.6, blue: 0.9)
        case .green: return Color(red: 0.3, green: 0.7, blue: 0.4)
        case .brown: return Color(red: 0.5, green: 0.3, blue: 0.15)
        case .hazel: return Color(red: 0.6, green: 0.4, blue: 0.2)
        }
    }
    
    var promptDescription: String {
        switch self {
        case .blue: return "blue eyes"
        case .green: return "green eyes"
        case .brown: return "brown eyes"
        case .hazel: return "hazel eyes"
        }
    }
}

// MARK: - Avatar Configuration
struct AvatarConfiguration: Codable, Equatable {
    var style: AvatarStyle = .cartoon
    var hairColor: HairColor = .brown
    var skinTone: SkinTone = .medium
    var eyeColor: EyeColor = .brown
    var clothingColor: CodableColor = CodableColor(color: .blue)
    
    static let `default` = AvatarConfiguration()
}

// MARK: - Codable Color Wrapper
struct CodableColor: Codable, Equatable {
    var red: Double
    var green: Double
    var blue: Double
    var opacity: Double
    
    init(color: Color) {
        let uiColor = UIColor(color)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        self.red = Double(r)
        self.green = Double(g)
        self.blue = Double(b)
        self.opacity = Double(a)
    }
    
    var color: Color {
        Color(red: red, green: green, blue: blue, opacity: opacity)
    }
}

// MARK: - Character Sheet
struct CharacterSheet: Codable, Equatable {
    var frontView: Data?
    var sideView: Data?
    var backView: Data?
    var createdAt: Date
    
    init(frontView: Data? = nil, sideView: Data? = nil, backView: Data? = nil) {
        self.frontView = frontView
        self.sideView = sideView
        self.backView = backView
        self.createdAt = Date()
    }
}

// MARK: - Generated Scene Image
struct GeneratedSceneImage: Codable, Equatable, Identifiable {
    var id: String
    var sceneIndex: Int
    var imageData: Data
    var prompt: String
    var generatedAt: Date
    
    init(sceneIndex: Int, imageData: Data, prompt: String) {
        self.id = "\(sceneIndex)_\(Date().timeIntervalSince1970)"
        self.sceneIndex = sceneIndex
        self.imageData = imageData
        self.prompt = prompt
        self.generatedAt = Date()
    }
}

// MARK: - Avatar Generation Status
enum AvatarGenerationStatus: Equatable {
    case notStarted
    case generating(step: String)
    case completed
    case failed(error: String)
}

// MARK: - Gender Selection Helper
enum GenderSelection: String, CaseIterable, Codable, Identifiable {
    case girl
    case boy
    case neutral
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .girl: return "Mädchen"
        case .boy: return "Junge"
        case .neutral: return "Neutral"
        }
    }
    
    var icon: String {
        switch self {
        case .girl: return "person.crop.circle.badge.checkmark"
        case .boy: return "person.crop.circle.fill"
        case .neutral: return "person.crop.circle"
        }
    }
    
    var emoji: String {
        switch self {
        case .girl: return "👧"
        case .boy: return "👦"
        case .neutral: return "🧒"
        }
    }
    
    var gradient: [Color] {
        switch self {
        case .girl: return [.pink, .purple]
        case .boy: return [.blue, .cyan]
        case .neutral: return [.green, .teal]
        }
    }
    
    var toChildGender: ChildGender {
        switch self {
        case .girl: return .female
        case .boy: return .male
        case .neutral: return .neutral
        }
    }
    
    static func from(_ gender: ChildGender) -> GenderSelection {
        switch gender {
        case .female: return .girl
        case .male: return .boy
        case .neutral: return .neutral
        }
    }
}