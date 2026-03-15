import SwiftUI

struct LibraryView: View {
    @EnvironmentObject var store: SDAppStore
    @State private var selectedStory: Story?
    @State private var showBookOpenAnimation = false
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Dark background
                Color(red: 0.12, green: 0.14, blue: 0.28)
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
                                    BookCoverWithOpenAnimation(
                                        story: story,
                                        onOpen: {
                                            selectedStory = story
                                            showBookOpenAnimation = true
                                        }
                                    )
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

// MARK: - Book Cover with Open Animation
struct BookCoverWithOpenAnimation: View {
    let story: Story
    let onOpen: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        BookCoverCard(story: story, isPressed: isPressed)
            .onTapGesture {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                    isPressed = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isPressed = false
                    onOpen()
                }
            }
    }
}

// MARK: - Book Cover Card
struct BookCoverCard: View {
    let story: Story
    let isPressed: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Cover
            ZStack(alignment: .bottom) {
                // Background
                RoundedRectangle(cornerRadius: 12)
                    .fill(coverGradient)
                    .frame(height: 200)
                
                // Illustration
                VStack {
                    Spacer()
                    
                    Image(systemName: coverIcon)
                        .font(.system(size: 70))
                        .foregroundStyle(.white)
                        .shadow(radius: 4)
                    
                    Spacer()
                }
                
                // Title overlay
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
                        colors: [.black.opacity(0.7), .black.opacity(0.3), .clear],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Spine
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.2))
                .frame(height: 4)
                .padding(.top, 2)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(
            color: .black.opacity(isPressed ? 0.5 : 0.3),
            radius: isPressed ? 16 : 10,
            x: 0,
            y: isPressed ? 12 : 6
        )
        .scaleEffect(isPressed ? 0.94 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isPressed)
    }
    
    private var coverGradient: LinearGradient {
        switch story.genre {
        case .adventure:
            return LinearGradient(colors: [.orange, .red.opacity(0.8)], startPoint: .top, endPoint: .bottom)
        case .friendship:
            return LinearGradient(colors: [.green, .teal.opacity(0.8)], startPoint: .top, endPoint: .bottom)
        case .fantasy:
            return LinearGradient(colors: [.purple, .pink.opacity(0.8)], startPoint: .top, endPoint: .bottom)
        case .animals:
            return LinearGradient(colors: [.brown, .orange.opacity(0.8)], startPoint: .top, endPoint: .bottom)
        case .bedtime:
            return LinearGradient(colors: [.blue, .indigo.opacity(0.8)], startPoint: .top, endPoint: .bottom)
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

// MARK: - Book Open Animation View
struct BookOpenAnimationView: View {
    let story: Story
    let onComplete: () -> Void
    
    @State private var coverOpenAmount: CGFloat = 0
    @State private var showPages = false
    @State private var pageFlipAmount: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Dark background
            Color.black.opacity(0.9)
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Book opening animation
                ZStack {
                    // Back cover (left side when open)
                    BookPageView(story: story, isLeft: true)
                        .frame(width: 160, height: 220)
                        .offset(x: -80 * coverOpenAmount)
                        .opacity(coverOpenAmount)
                    
                    // Front cover (starts closed, opens to right)
                    BookCoverAnimated(story: story, openAmount: coverOpenAmount)
                        .frame(width: 160, height: 220)
                        .rotation3DEffect(
                            .degrees(-180 * coverOpenAmount),
                            axis: (x: 0, y: 1, z: 0),
                            anchor: .leading
                        )
                    
                    // First page (flips in)
                    if showPages {
                        BookPageView(story: story, isLeft: false)
                            .frame(width: 160, height: 220)
                            .offset(x: 80)
                            .rotation3DEffect(
                                .degrees(-180 * pageFlipAmount),
                                axis: (x: 0, y: 1, z: 0),
                                anchor: .leading
                            )
                            .opacity(pageFlipAmount < 0.5 ? 0 : 1)
                    }
                }
                
                Spacer()
                
                // Loading text
                Text("Geschichte wird geöffnet...")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .onAppear {
            // Animation sequence
            withAnimation(.easeInOut(duration: 0.8)) {
                coverOpenAmount = 1
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                showPages = true
                withAnimation(.easeInOut(duration: 0.6)) {
                    pageFlipAmount = 1
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                onComplete()
            }
        }
    }
}

// MARK: - Animated Book Cover
struct BookCoverAnimated: View {
    let story: Story
    let openAmount: CGFloat
    
    var body: some View {
        ZStack {
            // Cover background
            RoundedRectangle(cornerRadius: 8)
                .fill(coverGradient)
            
            // Cover content
            VStack {
                Spacer()
                Image(systemName: coverIcon)
                    .font(.system(size: 50))
                    .foregroundColor(.white)
                    .opacity(1 - openAmount)
                Spacer()
            }
            
            // Spine
            HStack {
                Rectangle()
                    .fill(Color.brown.opacity(0.8))
                    .frame(width: 12)
                Spacer()
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.white.opacity(0.3), lineWidth: 2)
        )
    }
    
    private var coverGradient: LinearGradient {
        switch story.genre {
        case .adventure:
            return LinearGradient(colors: [.orange, .red], startPoint: .top, endPoint: .bottom)
        case .friendship:
            return LinearGradient(colors: [.green, .teal], startPoint: .top, endPoint: .bottom)
        case .fantasy:
            return LinearGradient(colors: [.purple, .pink], startPoint: .top, endPoint: .bottom)
        case .animals:
            return LinearGradient(colors: [.brown, .orange], startPoint: .top, endPoint: .bottom)
        case .bedtime:
            return LinearGradient(colors: [.blue, .indigo], startPoint: .top, endPoint: .bottom)
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

// MARK: - Book Page View
struct BookPageView: View {
    let story: Story
    let isLeft: Bool
    
    var body: some View {
        ZStack {
            // Page background
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.2), radius: 4, x: isLeft ? -2 : 2, y: 2)
            
            // Page content
            VStack(spacing: 12) {
                if isLeft {
                    // Left page - title
                    Image(systemName: iconForGenre(story.genre))
                        .font(.system(size: 40))
                        .foregroundColor(colorForGenre(story.genre))
                    
                    Text(story.title)
                        .font(.system(size: 16, weight: .bold, design: .serif))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                    
                    Text(story.moral)
                        .font(.system(size: 12, weight: .medium, design: .serif))
                        .foregroundColor(.gray)
                        .italic()
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                } else {
                    // Right page - preview
                    Text("Kapitel 1")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.gray)
                    
                    Text(story.scenes.first?.text ?? "")
                        .font(.system(size: 13, design: .serif))
                        .foregroundColor(.black)
                        .lineLimit(8)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal, 12)
                    
                    Spacer()
                    
                    Text("...")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
            }
            .padding(.vertical, 20)
        }
    }
    
    private func iconForGenre(_ genre: StoryGenre) -> String {
        switch genre {
        case .adventure: return "map.fill"
        case .friendship: return "heart.fill"
        case .fantasy: return "sparkles"
        case .animals: return "pawprint.fill"
        case .bedtime: return "moon.fill"
        }
    }
    
    private func colorForGenre(_ genre: StoryGenre) -> Color {
        switch genre {
        case .adventure: return .orange
        case .friendship: return .green
        case .fantasy: return .purple
        case .animals: return .brown
        case .bedtime: return .blue
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

#Preview {
    LibraryView()
        .environmentObject(SDAppStore())
}