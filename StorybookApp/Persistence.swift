import Foundation

protocol PersistenceService {
    func saveChildren(_ children: [ChildProfile])
    func loadChildren() -> [ChildProfile]
    func saveStories(_ stories: [Story])
    func loadStories() -> [Story]
}

final class UserDefaultsPersistenceService: PersistenceService {
    private let childrenKey = "storybook.children"
    private let storiesKey = "storybook.stories"

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init() {
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }

    func saveChildren(_ children: [ChildProfile]) {
        if let data = try? encoder.encode(children) {
            UserDefaults.standard.set(data, forKey: childrenKey)
        }
    }

    func loadChildren() -> [ChildProfile] {
        guard let data = UserDefaults.standard.data(forKey: childrenKey),
              let items = try? decoder.decode([ChildProfile].self, from: data) else { return [] }
        return items
    }

    func saveStories(_ stories: [Story]) {
        if let data = try? encoder.encode(stories) {
            UserDefaults.standard.set(data, forKey: storiesKey)
        }
    }

    func loadStories() -> [Story] {
        guard let data = UserDefaults.standard.data(forKey: storiesKey),
              let items = try? decoder.decode([Story].self, from: data) else { return [] }
        return items
    }
}
