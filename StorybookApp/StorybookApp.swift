import SwiftUI
import SwiftData

@main
struct StorybookApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [ChildProfile.self, Story.self, AppSettings.self])
    }
}