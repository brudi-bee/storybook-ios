import Foundation

// MARK: - Persistence Service Protocol
// This protocol uses DTOs for backward compatibility with existing code.
// The app primarily uses SwiftData for persistence now.
protocol PersistenceService {
    func saveChildren(_ children: [ChildProfileDTO])
    func loadChildren() -> [ChildProfileDTO]
    func saveStories(_ stories: [StoryDTO])
    func loadStories() -> [StoryDTO]
}

// MARK: - UserDefaults Persistence (Legacy)
// Note: The app now uses SwiftData as primary persistence.
// This service is kept for backward compatibility and migration purposes.
final class UserDefaultsPersistenceService: PersistenceService {
    private let childrenKey = "storybook.children"
    private let storiesKey = "storybook.stories"

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init() {
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }

    func saveChildren(_ children: [ChildProfileDTO]) {
        if let data = try? encoder.encode(children) {
            UserDefaults.standard.set(data, forKey: childrenKey)
        }
    }

    func loadChildren() -> [ChildProfileDTO] {
        guard let data = UserDefaults.standard.data(forKey: childrenKey),
              let items = try? decoder.decode([ChildProfileDTO].self, from: data) else { return [] }
        return items
    }

    func saveStories(_ stories: [StoryDTO]) {
        if let data = try? encoder.encode(stories) {
            UserDefaults.standard.set(data, forKey: storiesKey)
        }
    }

    func loadStories() -> [StoryDTO] {
        guard let data = UserDefaults.standard.data(forKey: storiesKey),
              let items = try? decoder.decode([StoryDTO].self, from: data) else { return [] }
        return items
    }
}
