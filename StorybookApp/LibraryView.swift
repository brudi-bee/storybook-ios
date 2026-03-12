import SwiftUI

struct LibraryView: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        NavigationStack {
            Group {
                if store.stories.isEmpty {
                    ContentUnavailableView(
                        "Noch keine Geschichten",
                        systemImage: "book.closed",
                        description: Text("Erstelle deine erste Geschichte im Generator.")
                    )
                } else {
                    List(store.stories) { story in
                        NavigationLink {
                            ReaderView(story: story)
                        } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(story.title)
                                    .font(.headline)
                                Text("\(story.genre.displayName) · \(story.setting)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Text(story.createdAt.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Bibliothek")
        }
    }
}
