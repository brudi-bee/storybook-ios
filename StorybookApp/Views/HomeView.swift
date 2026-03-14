import SwiftUI
import UIKit

struct HomeView: View {
    @EnvironmentObject var store: SDAppStore
    @State private var selectedStory: Story?
    @State private var showingStoryDetail = false
    @State private var showingLibrary = false
    @State private var isRefreshing = false
    @State private var showNeedsChildAlert = false
    
    // Haptic feedback generators
    private let selectionFeedback = UISelectionFeedbackGenerator()
    private let impactFeedback = UIImpactFeedbackGenerator(style: .light)
    
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
            .refreshable {
                await refreshLibrary()
            }
            .navigationTitle("Storybook")
            .sheet(item: $selectedStory) { story in
                ReaderView(story: convertToDTO(story))
            }
            .navigationDestination(isPresented: $showingLibrary) {
                LibraryView()
            }
            .alert("Bitte erst ein Kinderprofil anlegen", isPresented: $showNeedsChildAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Lege zuerst im Tab ‚Kinder‘ mindestens ein Profil an. Danach sind Geschichten personalisiert mit Name und Geschlecht.")
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
            
            Text(store.children.first.map { "Für \($0.name)" } ?? "Für deine Kleinen")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if store.children.isEmpty {
                Label("Bitte zuerst ein Kind im Tab ‚Kinder‘ anlegen", systemImage: "person.badge.plus")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.orange)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Capsule().fill(Color.orange.opacity(0.12))
                    )
            }
            
            Text("Jede Woche neu kuratierte Geschichte")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.purple)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color.purple.opacity(0.12))
                )
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
                    showingLibrary = true
                }
                .font(.subheadline)
                .foregroundStyle(.purple)
                .accessibilityLabel("Alle empfohlenen Geschichten anzeigen")
            }
            .padding(.horizontal)
            
            // Horizontal Scroll
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(store.featuredStories) { story in
                        FeaturedStoryCard(story: story)
                            .onTapGesture {
                                // Haptic feedback
                                impactFeedback.impactOccurred()
                                // Load story
                                loadFeaturedStory(story)
                            }
                            .accessibilityLabel("\(story.title), \(story.subtitle)")
                            .accessibilityHint("Tippe um die Geschichte zu lesen")
                            .accessibilityAddTraits(.isButton)
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
                                // Haptic feedback
                                selectionFeedback.selectionChanged()
                                selectedStory = story
                            }
                            .accessibilityLabel("\(story.title), Genre: \(story.genre.displayName)")
                            .accessibilityHint("Tippe um die Geschichte zu lesen")
                            .accessibilityAddTraits(.isButton)
                    }
                }
                .padding(.horizontal)
                
                // "Alle anzeigen" Button when >6 stories
                if store.stories.count > 6 {
                    Button {
                        showingLibrary = true
                    } label: {
                        HStack {
                            Text("Alle anzeigen")
                                .font(.subheadline.weight(.medium))
                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.semibold))
                        }
                        .foregroundStyle(.purple)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(
                            Capsule()
                                .fill(Color.purple.opacity(0.1))
                        )
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 8)
                    .accessibilityLabel("Alle Geschichten in der Bibliothek anzeigen")
                    .accessibilityHint("Zeigt die vollständige Bibliothek mit \(store.stories.count) Geschichten")
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    private func loadFeaturedStory(_ featured: FeaturedStory) {
        guard !store.children.isEmpty else {
            showNeedsChildAlert = true
            return
        }

        if let story = store.stories.first(where: { $0.id == featured.id }) {
            selectedStory = story
        }
    }
    
    private func convertToDTO(_ story: Story) -> StoryDTO {
        return StoryDTO(
            id: story.id,
            title: story.title,
            language: story.language,
            genre: story.genre,
            setting: story.setting,
            moral: story.moral,
            children: [],
            scenes: story.scenes,
            createdAt: story.createdAt
        )
    }
    
    private func refreshLibrary() async {
        // Simulate network refresh with haptic feedback
        await MainActor.run {
            selectionFeedback.prepare()
            store.loadStories()
            selectionFeedback.selectionChanged()
        }
        // Small delay to show the refresh indicator
        try? await Task.sleep(nanoseconds: 500_000_000)
    }
}

// MARK: - Card Style Constants
enum CardStyle {
    static let cornerRadius: CGFloat = 20
    static let shadowColor = Color.black.opacity(0.1)
    static let shadowRadius: CGFloat = 8
    static let shadowX: CGFloat = 0
    static let shadowY: CGFloat = 4
}

// MARK: - Featured Story Card
struct FeaturedStoryCard: View {
    let story: FeaturedStory
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image Area
            ZStack {
                RoundedRectangle(cornerRadius: CardStyle.cornerRadius)
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
                .clipShape(RoundedRectangle(cornerRadius: CardStyle.cornerRadius))
            }
            .frame(width: 260, height: 180)
            .clipShape(RoundedRectangle(cornerRadius: CardStyle.cornerRadius))
            
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
        .storyCardStyle()
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Compact Story Card
struct CompactStoryCard: View {
    let story: Story
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Image Placeholder
            ZStack {
                RoundedRectangle(cornerRadius: CardStyle.cornerRadius)
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
        .storyCardStyle()
        .accessibilityElement(children: .combine)
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
