import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: SDAppStore
    @State private var selectedStory: Story?
    @State private var showingStoryDetail = false
    @State private var showingGenerator = false
    
    // 3 Dummy Stories für den Start
    let featuredStories: [FeaturedStory] = [
        FeaturedStory(
            id: UUID(),
            title: "Luna und der Sternenwald",
            subtitle: "Ein magisches Abenteuer",
            genre: .fantasy,
            color: .purple,
            gradient: [.purple, .pink],
            image: "sparkles"
        ),
        FeaturedStory(
            id: UUID(),
            title: "Max und die Mutprobe",
            subtitle: "Wenn Angst zu Freundschaft wird",
            genre: .adventure,
            color: .orange,
            gradient: [.orange, .red],
            image: "flame"
        ),
        FeaturedStory(
            id: UUID(),
            title: "Die Freundschaftsinsel",
            subtitle: "Zusammen sind wir stark",
            genre: .friendship,
            color: .green,
            gradient: [.green, .teal],
            image: "leaf"
        )
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Hero Section
                    heroSection
                    
                    // Featured Stories Grid
                    featuredSection
                    
                    // Library Section
                    librarySection
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Storybook")
            .sheet(item: $selectedStory) { story in
                ReaderView(story: story)
            }
            .navigationDestination(isPresented: $showingGenerator) {
                GeneratorView()
            }
        }
    }
    
    // MARK: - Hero Section
    private var heroSection: some View {
        VStack(spacing: 16) {
            // App Icon / Logo Placeholder
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.purple, .blue, .pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .shadow(color: .purple.opacity(0.3), radius: 20, x: 0, y: 10)
                
                Image(systemName: "book.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(.white)
            }
            
            Text("Magische Geschichten")
                .font(.title.bold())
            
            Text(store.children.first?.name.map { "Für \($0)" } ?? "Für deine Kleinen")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            // Quick Action Button
            Button {
                showingGenerator = true
            } label: {
                HStack {
                    Image(systemName: "wand.and.stars")
                    Text("Neue Geschichte")
                }
                .font(.headline)
                .foregroundStyle(.white)
                .padding()
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.purple, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
            }
            .padding(.top, 8)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(.background)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
        .padding()
    }
    
    // MARK: - Featured Section
    private var featuredSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Empfohlene Geschichten")
                    .font(.title3.bold())
                
                Spacer()
                
                Button("Alle") {
                    // Show all
                }
                .font(.subheadline)
                .foregroundStyle(.purple)
            }
            .padding(.horizontal)
            
            // Horizontal Scroll
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(featuredStories) { story in
                        FeaturedStoryCard(story: story)
                            .onTapGesture {
                                // Load story
                                loadFeaturedStory(story)
                            }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Library Section
    private var librarySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Deine Bibliothek")
                    .font(.title3.bold())
                
                Spacer()
                
                Text("\(store.stories.count) Geschichten")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            
            if store.stories.isEmpty {
                // Empty State
                VStack(spacing: 12) {
                    Image(systemName: "book.closed")
                        .font(.system(size: 60))
                        .foregroundStyle(.secondary.opacity(0.5))
                    
                    Text("Noch keine Geschichten")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    Text("Erstelle deine erste Geschichte!")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, minHeight: 200)
                .padding()
            } else {
                // Story Grid
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 160), spacing: 16)
                ], spacing: 16) {
                    ForEach(store.stories.prefix(6)) { story in
                        CompactStoryCard(story: story)
                            .onTapGesture {
                                selectedStory = story
                            }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func loadFeaturedStory(_ featured: FeaturedStory) {
        // Convert featured to real Story and open
        let scenes = [
            StoryScene(index: 1, text: "Es war einmal...", imagePrompt: "fantasy forest", bgmMood: "calm"),
            StoryScene(index: 2, text: "Und sie lebten glücklich bis ans Ende ihrer Tage.", imagePrompt: "happy ending", bgmMood: "peaceful")
        ]
        
        let story = Story(
            title: featured.title,
            language: .de,
            genre: featured.genre,
            setting: featured.subtitle,
            moral: "Freundschaft und Mut",
            scenes: scenes
        )
        
        selectedStory = story
    }
}

// MARK: - Featured Story Model
struct FeaturedStory: Identifiable {
    let id: UUID
    let title: String
    let subtitle: String
    let genre: StoryGenre
    let color: Color
    let gradient: [Color]
    let image: String
}

// MARK: - Featured Story Card
struct FeaturedStoryCard: View {
    let story: FeaturedStory
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image Area
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: story.gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 260, height: 180)
                
                Image(systemName: story.image)
                    .font(.system(size: 60))
                    .foregroundStyle(.white.opacity(0.8))
                    .shadow(radius: 10)
                
                // Gradient Overlay for better text visibility
                VStack {
                    Spacer()
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.4)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 60)
                }
                .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            .frame(width: 260, height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            
            // Text Area
            VStack(alignment: .leading, spacing: 4) {
                Text(story.title)
                    .font(.headline)
                    .lineLimit(2)
                
                Text(story.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .padding(12)
            .frame(width: 260, alignment: .leading)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.background)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
}

// MARK: - Compact Story Card
struct CompactStoryCard: View {
    let story: Story
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Image Placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(genreColor(for: story.genre).opacity(0.3))
                    .frame(height: 120)
                
                Image(systemName: iconForGenre(story.genre))
                    .font(.system(size: 40))
                    .foregroundStyle(genreColor(for: story.genre))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(story.title)
                    .font(.subheadline.bold())
                    .lineLimit(2)
                
                Text(story.setting)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.background)
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 3)
        )
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
    
    private func iconForGenre(_ genre: StoryGenre) -> String {
        switch genre {
        case .adventure: return "bolt.fill"
        case .friendship: return "heart.fill"
        case .fantasy: return "sparkles"
        case .animals: return "pawprint.fill"
        case .bedtime: return "moon.fill"
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(SDAppStore())
}
