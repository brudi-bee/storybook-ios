import SwiftUI

private enum RootTab: Hashable {
    case home
    case library
    case profiles
}

struct RootView: View {
    @StateObject private var store = SDAppStore()
    @State private var selectedTab: RootTab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem { Label("Start", systemImage: "house.fill") }
                .tag(RootTab.home)

            LibraryView()
                .tabItem { Label("Bibliothek", systemImage: "books.vertical") }
                .tag(RootTab.library)

            ProfilesView()
                .tabItem { Label("Kinder", systemImage: "person.2") }
                .tag(RootTab.profiles)
        }
        .environmentObject(store)
    }
}

#Preview {
    RootView()
}
