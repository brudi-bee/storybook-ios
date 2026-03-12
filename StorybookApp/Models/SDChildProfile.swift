import Foundation
import SwiftData

@Model
 final class ChildProfile {
    @Attribute(.unique) var id: UUID
    var name: String
    var genderRaw: String // ChildGender als String speichern
    var order: Int // 0 oder 1
    
    var gender: ChildGender {
        ChildGender(rawValue: genderRaw) ?? .neutral
    }
    
    init(name: String, gender: ChildGender, order: Int) {
        self.id = UUID()
        self.name = name
        self.genderRaw = gender.rawValue
        self.order = order
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
