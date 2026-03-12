import SwiftUI

struct StoryCard: View {
    let story: Story
    var onDelete: () -> Void = {}
    var onFavorite: () -> Void = {}
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Top Row: Genre badge + Date
            HStack {
                GenreBadge(genre: story.genre)
                Spacer()
                Text(story.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            // Title
            Text(story.title)
                .font(.title3.bold())
                .lineLimit(2)
            
            // Setting & Moral
            HStack(spacing: 8) {
                Label(story.setting, systemImage: "mappin")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text("·")
                    .foregroundStyle(.tertiary)
                
                Label(story.moral, systemImage: "heart")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            // Stats bar
            HStack {
                Label("\(story.scenes.count) Szenen", systemImage: "doc.text")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                // Read count
                if story.readCount > 0 {
                    Label("\(story.readCount)× gelesen", systemImage: "eye")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                // Favorite button
                Button(action: onFavorite) {
                    Image(systemName: story.isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(story.isFavorite ? .red : .secondary)
                }
                .buttonStyle(.borderless)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.background)
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [
                            genreColor(for: story.genre).opacity(0.3),
                            .clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .swipeActions(edge: .trailing) {
            Button(role: .destructive, action: onDelete) {
                Label("Löschen", systemImage: "trash")
            }
            
            Button(action: onFavorite) {
                Label("Favorit", systemImage: story.isFavorite ? "heart.slash" : "heart")
            }
            .tint(.red)
        }
    }
    
    private func genreColor(for genre: StoryGenre) -> Color {
        switch genre {
        case .adventure: return .orange
        case .friendship: return .green
        case .fantasy: return .purple
        case .animals: return .brown
        case .bedtime: return .blue
        }
    }
}

struct GenreBadge: View {
    let genre: StoryGenre
    
    var body: some View {
        Text(genre.displayName)
            .font(.caption.weight(.medium))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(color.opacity(0.15))
            )
            .foregroundStyle(color)
    }
    
    private var color: Color {
        switch genre {
        case .adventure: return .orange
        case .friendship: return .green
        case .fantasy: return .purple
        case .animals: return .brown
        case .bedtime: return .blue
        }
    }
}

#Preview {
    StoryCard(story: Story(
        title: "Lunas magisches Abenteuer",
        language: .de,
        genre: .fantasy,
        setting: "Sternenwald",
        moral: "Mut",
        scenes: []
    ))
    .padding()
}
