import SwiftUI

struct RootView: View {
    @StateObject private var store = SDAppStore()

    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Start", systemImage: "house.fill") }

            GeneratorView()
                .tabItem { Label("Generieren", systemImage: "wand.and.stars") }

            LibraryView()
                .tabItem { Label("Bibliothek", systemImage: "books.vertical") }

            ProfilesView()
                .tabItem { Label("Kinder", systemImage: "person.2") }
        }
        .environmentObject(store)
    }
}

#Preview {
    RootView()
}
