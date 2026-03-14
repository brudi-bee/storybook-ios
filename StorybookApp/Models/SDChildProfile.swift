import Foundation
import SwiftData
import SwiftUI
import UIKit

@Model
final class ChildProfile {
    @Attribute(.unique) var id: UUID
    var name: String
    var genderRaw: String // ChildGender als String speichern
    var order: Int // 0 oder 1
    
    // MARK: - Avatar Properties
    var avatarStyleRaw: String?
    var hairColorRaw: String?
    var skinToneRaw: String?
    var eyeColorRaw: String?
    var clothingColorRed: Double?
    var clothingColorGreen: Double?
    var clothingColorBlue: Double?
    var clothingColorOpacity: Double?
    var avatarImageData: Data?
    var characterSheetJSON: String? // JSON encoded CharacterSheet
    
    var gender: ChildGender {
        ChildGender(rawValue: genderRaw) ?? .neutral
    }
    
    // MARK: - Avatar Computed Properties
    var avatarStyle: AvatarStyle {
        get { AvatarStyle(rawValue: avatarStyleRaw ?? "") ?? .cartoon }
        set { avatarStyleRaw = newValue.rawValue }
    }
    
    var hairColor: HairColor {
        get { HairColor(rawValue: hairColorRaw ?? "") ?? .brown }
        set { hairColorRaw = newValue.rawValue }
    }
    
    var skinTone: SkinTone {
        get { SkinTone(rawValue: skinToneRaw ?? "") ?? .medium }
        set { skinToneRaw = newValue.rawValue }
    }
    
    var eyeColor: EyeColor {
        get { EyeColor(rawValue: eyeColorRaw ?? "") ?? .brown }
        set { eyeColorRaw = newValue.rawValue }
    }
    
    var clothingColor: Color {
        get {
            guard let r = clothingColorRed,
                  let g = clothingColorGreen,
                  let b = clothingColorBlue,
                  let a = clothingColorOpacity else {
                return .blue
            }
            return Color(red: r, green: g, blue: b, opacity: a)
        }
        set {
            let uiColor = UIColor(newValue)
            var r: CGFloat = 0
            var g: CGFloat = 0
            var b: CGFloat = 0
            var a: CGFloat = 0
            uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
            clothingColorRed = Double(r)
            clothingColorGreen = Double(g)
            clothingColorBlue = Double(b)
            clothingColorOpacity = Double(a)
        }
    }
    
    var characterSheet: CharacterSheet? {
        get {
            guard let json = characterSheetJSON,
                  let data = json.data(using: .utf8),
                  let sheet = try? JSONDecoder().decode(CharacterSheet.self, from: data) else {
                return nil
            }
            return sheet
        }
        set {
            if let sheet = newValue,
               let data = try? JSONEncoder().encode(sheet),
               let string = String(data: data, encoding: .utf8) {
                characterSheetJSON = string
            } else {
                characterSheetJSON = nil
            }
        }
    }
    
    var hasAvatar: Bool {
        avatarImageData != nil
    }
    
    var avatarConfiguration: AvatarConfiguration {
        get {
            AvatarConfiguration(
                style: avatarStyle,
                hairColor: hairColor,
                skinTone: skinTone,
                eyeColor: eyeColor,
                clothingColor: CodableColor(color: clothingColor)
            )
        }
        set {
            avatarStyle = newValue.style
            hairColor = newValue.hairColor
            skinTone = newValue.skinTone
            eyeColor = newValue.eyeColor
            clothingColor = newValue.clothingColor.color
        }
    }
    
    init(name: String, gender: ChildGender, order: Int) {
        self.id = UUID()
        self.name = name
        self.genderRaw = gender.rawValue
        self.order = order
        
        // Default avatar values
        self.avatarStyleRaw = AvatarStyle.cartoon.rawValue
        self.hairColorRaw = HairColor.brown.rawValue
        self.skinToneRaw = SkinTone.medium.rawValue
        self.eyeColorRaw = EyeColor.brown.rawValue
        
        // Default clothing color (blue)
        let defaultColor = UIColor(Color.blue)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        defaultColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        self.clothingColorRed = Double(r)
        self.clothingColorGreen = Double(g)
        self.clothingColorBlue = Double(b)
        self.clothingColorOpacity = Double(a)
    }
    
    // MARK: - Avatar Update Methods
    func updateAvatarConfiguration(_ config: AvatarConfiguration) {
        self.avatarConfiguration = config
    }
    
    func setAvatarImage(_ data: Data) {
        self.avatarImageData = data
    }
    
    func setCharacterSheet(_ sheet: CharacterSheet) {
        self.characterSheet = sheet
    }
    
    func clearAvatar() {
        self.avatarImageData = nil
        self.characterSheetJSON = nil
    }
}

@Model
final class Story {
    @Attribute(.unique) var id: UUID
    var title: String
    var languageRaw: String
    var genreRaw: String
    var setting: String
    var moral: String
    var createdAt: Date
    var scenesJSON: String // als JSON string gespeichert
    var isFavorite: Bool
    var readCount: Int
    
    // MARK: - Character Reference
    var characterReferenceImageData: Data?
    var generatedImagesJSON: String? // JSON encoded [String: Data] for scene images
    
    var language: StoryLanguage {
        StoryLanguage(rawValue: languageRaw) ?? .de
    }
    
    var genre: StoryGenre {
        StoryGenre(rawValue: genreRaw) ?? .bedtime
    }
    
    var scenes: [StoryScene] {
        get {
            guard let data = scenesJSON.data(using: .utf8),
                  let decoded = try? JSONDecoder().decode([StoryScene].self, from: data) else {
                return []
            }
            return decoded
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue),
               let string = String(data: encoded, encoding: .utf8) {
                scenesJSON = string
            }
        }
    }
    
    var generatedImages: [String: Data] {
        get {
            guard let json = generatedImagesJSON,
                  let data = json.data(using: .utf8),
                  let decoded = try? JSONDecoder().decode([String: Data].self, from: data) else {
                return [:]
            }
            return decoded
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue),
               let string = String(data: encoded, encoding: .utf8) {
                generatedImagesJSON = string
            }
        }
    }
    
    var characterReferenceImage: Data? {
        get { characterReferenceImageData }
        set { characterReferenceImageData = newValue }
    }
    
    var hasGeneratedImages: Bool {
        !generatedImages.isEmpty
    }
    
    var hasCharacterReference: Bool {
        characterReferenceImageData != nil
    }
    
    init(title: String, language: StoryLanguage, genre: StoryGenre, setting: String, moral: String, scenes: [StoryScene]) {
        self.id = UUID()
        self.title = title
        self.languageRaw = language.rawValue
        self.genreRaw = genre.rawValue
        self.setting = setting
        self.moral = moral
        self.createdAt = Date()
        self.isFavorite = false
        self.readCount = 0
        
        // Encode scenes
        if let encoded = try? JSONEncoder().encode(scenes),
           let string = String(data: encoded, encoding: .utf8) {
            self.scenesJSON = string
        } else {
            self.scenesJSON = "[]"
        }
    }
    
    // MARK: - Image Management Methods
    func setSceneImage(_ imageData: Data, forSceneIndex index: Int) {
        var images = generatedImages
        images["\(index)"] = imageData
        generatedImages = images
    }
    
    func getSceneImage(forSceneIndex index: Int) -> Data? {
        generatedImages["\(index)"]
    }
    
    func setCharacterReference(_ imageData: Data) {
        self.characterReferenceImageData = imageData
    }
    
    func clearGeneratedImages() {
        self.generatedImagesJSON = nil
    }
}

@Model
final class AppSettings {
    @Attribute(.unique) var id: UUID
    var defaultLanguageRaw: String
    var maxStoriesToKeep: Int
    var sleepTimerDefault: Int // Minuten
    var musicDefaultOn: Bool
    var contentFilteringEnabled: Bool // Parental control
    var maxDailyStories: Int // 0 = unbegrenzt
    var dailyStoryCountUsed: Int
    var lastResetDate: Date?
    
    // MARK: - Avatar Generation Settings
    var useRealAvatarGeneration: Bool // true = DALL-E, false = mock
    var avatarGenerationQuality: String // standard, hd
    var autoGenerateCharacterSheet: Bool
    
    var defaultLanguage: StoryLanguage {
        get { StoryLanguage(rawValue: defaultLanguageRaw) ?? .de }
        set { defaultLanguageRaw = newValue.rawValue }
    }
    
    init() {
        self.id = UUID()
        self.defaultLanguageRaw = StoryLanguage.de.rawValue
        self.maxStoriesToKeep = 50
        self.sleepTimerDefault = 0
        self.musicDefaultOn = true
        self.contentFilteringEnabled = true
        self.maxDailyStories = 10
        self.dailyStoryCountUsed = 0
        self.lastResetDate = nil
        
        // Avatar defaults
        self.useRealAvatarGeneration = false // Default to mock for safety
        self.avatarGenerationQuality = "standard"
        self.autoGenerateCharacterSheet = true
    }
    
    func checkAndResetDailyIfNeeded() {
        let calendar = Calendar.current
        if let lastReset = lastResetDate,
           calendar.isDateInToday(lastReset) {
            return // Heute bereits zurückgesetzt
        }
        dailyStoryCountUsed = 0
        lastResetDate = Date()
    }
    
    func canGenerateNewStory() -> Bool {
        checkAndResetDailyIfNeeded()
        if maxDailyStories == 0 { return true }
        return dailyStoryCountUsed < maxDailyStories
    }
    
    func incrementStoryCount() {
        dailyStoryCountUsed += 1
    }
}