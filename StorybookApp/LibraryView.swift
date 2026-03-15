import SwiftUI

struct LibraryView: View {
    @EnvironmentObject var store: SDAppStore
    @State private var selectedStory: Story?
    @State private var showingReader = false
    
    // 2 columns for iPhone, 3 for iPad
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Dark background like reference
                Color(red: 0.15, green: 0.18, blue: 0.35)
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Header
                        HStack {
                            Text("Meine Bibliothek")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Text("\(store.stories.count) Geschichten")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 60)
                        .padding(.bottom, 24)
                        
                        if store.stories.isEmpty {
                            EmptyLibraryView()
                        } else {
                            // Books Grid
                            LazyVGrid(columns: columns, spacing: 20) {
                                ForEach(store.stories) { story in
                                    BookCoverCard(story: story)
                                        .onTapGesture {
                                            selectedStory = story
                                            showingReader = true
                                        }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 40)
                        }
                    }
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .fullScreenCover(item: $selectedStory) { story in
                ReaderView(story: convertToDTO(story))
            }
        }
    }
    
    private func convertToDTO(_ story: Story) -> StoryDTO {
        StoryDTO(
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
}

// MARK: - Empty Library View
struct EmptyLibraryView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "books.vertical")
                .font(.system(size: 80))
                .foregroundColor(.white.opacity(0.3))
            
            Text("Noch keine Geschichten")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
            
            Text("Erstelle ein Kinderprofil und öffne eine Geschichte.")
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, minHeight: 300)
        .padding()
    }
}

// MARK: - Book Cover Card
struct BookCoverCard: View {
    let story: Story
    @State private var isPressed = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Cover Image Area
            ZStack(alignment: .bottom) {
                // Background gradient based on genre
                RoundedRectangle(cornerRadius: 12)
                    .fill(coverGradient)
                    .frame(height: 200)
                
                // Illustration placeholder (would be actual image)
                VStack {
                    Spacer()
                    
                    // Character/Scene illustration
                    ZStack {
                        // Background shapes for depth
                        Circle()
                            .fill(.white.opacity(0.1))
                            .frame(width: 120, height: 120)
                            .offset(y: -20)
                        
                        // Main illustration icon
                        Image(systemName: coverIcon)
                            .font(.system(size: 70))
                            .foregroundStyle(.white)
                            .shadow(radius: 4)
                    }
                    
                    Spacer()
                }
                
                // Title overlay at bottom
                VStack(spacing: 4) {
                    Text(story.title)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .shadow(radius: 2)
                    
                    Text(story.genre.displayName)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        colors: [.black.opacity(0.6), .black.opacity(0.3), .clear],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Book spine effect (bottom edge)
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.3))
                .frame(height: 4)
                .padding(.top, 2)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
        )
        .overlay(
            // Subtle border
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(
            color: .black.opacity(isPressed ? 0.4 : 0.25),
            radius: isPressed ? 12 : 8,
            x: 0,
            y: isPressed ? 8 : 4
        )
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isPressed)
        .onPressingChanged { pressing in
            isPressed = pressing
        }
    }
    
    private var coverGradient: LinearGradient {
        switch story.genre {
        case .adventure:
            return LinearGradient(
                colors: [Color.orange, Color.red.opacity(0.8)],
                startPoint: .top,
                endPoint: .bottom
            )
        case .friendship:
            return LinearGradient(
                colors: [Color.green, Color.teal.opacity(0.8)],
                startPoint: .top,
                endPoint: .bottom
            )
        case .fantasy:
            return LinearGradient(
                colors: [Color.purple, Color.pink.opacity(0.8)],
                startPoint: .top,
                endPoint: .bottom
            )
        case .animals:
            return LinearGradient(
                colors: [Color.brown, Color.orange.opacity(0.8)],
                startPoint: .top,
                endPoint: .bottom
            )
        case .bedtime:
            return LinearGradient(
                colors: [Color.blue, Color.indigo.opacity(0.8)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
    
    private var coverIcon: String {
        switch story.genre {
        case .adventure: return "map.fill"
        case .friendship: return "heart.fill"
        case .fantasy: return "sparkles"
        case .animals: return "pawprint.fill"
        case .bedtime: return "moon.fill"
        }
    }
}

// MARK: - Press Gesture Helper
extension View {
    func onPressingChanged(_ action: @escaping (Bool) -> Void) -> some View {
        self.gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in action(true) }
                .onEnded { _ in action(false) }
        )
    }
}

#Preview {
    LibraryView()
        .environmentObject(SDAppStore())
}