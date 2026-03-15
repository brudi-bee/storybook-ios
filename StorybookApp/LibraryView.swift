import SwiftUI

struct LibraryView: View {
    @EnvironmentObject var store: SDAppStore
    @State private var selectedStory: Story?
    @State private var isAnimating = false
    
    let columns = [
        GridItem(.adaptive(minimum: 140, maximum: 160), spacing: 20)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                DesignTokens.Colors.warmBackground
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Text("Meine Bibliothek")
                                .font(DesignTokens.Typography.displaySmall)
                                .foregroundColor(DesignTokens.Colors.textPrimary)
                            
                            Text("\(store.stories.count) Geschichten")
                                .font(DesignTokens.Typography.bodyMedium)
                                .foregroundColor(DesignTokens.Colors.textSecondary)
                        }
                        .padding(.top, 20)
                        
                        if store.stories.isEmpty {
                            EmptyLibraryView()
                        } else {
                            // Bookshelf Grid
                            LazyVGrid(columns: columns, spacing: 30) {
                                ForEach(Array(store.stories.enumerated()), id: \.element.id) { index, story in
                                    BookView(
                                        story: story,
                                        index: index,
                                        onTap: {
                                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                                selectedStory = story
                                            }
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
            .sheet(item: $selectedStory) { story in
                BookOpenAnimationView(story: story)
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
                .foregroundColor(DesignTokens.Colors.textTertiary)
            
            Text("Noch keine Bücher")
                .font(DesignTokens.Typography.headlineMedium)
                .foregroundColor(DesignTokens.Colors.textSecondary)
            
            Text("Erstelle ein Kinderprofil und öffne eine Geschichte, um deine Sammlung zu starten.")
                .font(DesignTokens.Typography.bodyMedium)
                .foregroundColor(DesignTokens.Colors.textTertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, minHeight: 300)
        .padding()
    }
}

// MARK: - Book View (3D Book on Shelf)
struct BookView: View {
    let story: Story
    let index: Int
    let onTap: () -> Void
    
    @State private var isPressed = false
    @State private var isHovered = false
    
    private var bookColors: (spine: Color, cover: Color, pages: Color) {
        switch story.genre {
        case .adventure:
            return (Color.orange.opacity(0.9), Color.orange, Color.white)
        case .friendship:
            return (Color.green.opacity(0.9), Color.green, Color.white)
        case .fantasy:
            return (Color.purple.opacity(0.9), Color.purple, Color.white)
        case .animals:
            return (Color.brown.opacity(0.9), Color.brown, Color.white)
        case .bedtime:
            return (Color.blue.opacity(0.9), Color.blue, Color.white)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 3D Book
            ZStack {
                // Book spine (left edge)
                RoundedRectangle(cornerRadius: 4)
                    .fill(bookColors.spine)
                    .frame(width: 24, height: 160)
                    .offset(x: -58)
                
                // Book cover
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: [bookColors.cover, bookColors.cover.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 160)
                    .shadow(
                        color: Color.black.opacity(isPressed ? 0.3 : 0.2),
                        radius: isPressed ? 8 : 6,
                        x: isPressed ? 4 : 2,
                        y: isPressed ? 8 : 4
                    )
                
                // Cover content
                VStack(spacing: 8) {
                    // Icon
                    Image(systemName: iconForGenre(story.genre))
                        .font(.system(size: 32))
                        .foregroundColor(.white.opacity(0.9))
                    
                    // Title
                    Text(story.title)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .rotationEffect(.degrees(-2))
                        .padding(.horizontal, 8)
                }
                .frame(width: 100, height: 140)
                
                // Pages edge (right side)
                RoundedRectangle(cornerRadius: 2)
                    .fill(bookColors.pages)
                    .frame(width: 8, height: 156)
                    .offset(x: 56)
                    .overlay(
                        // Page lines
                        VStack(spacing: 2) {
                            ForEach(0..<20) { _ in
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 0.5)
                            }
                        }
                        .frame(height: 150)
                    )
            }
            .rotation3DEffect(
                .degrees(isPressed ? -15 : (isHovered ? -5 : 0)),
                axis: (x: 0, y: 1, z: 0),
                anchor: .leading
            )
            .offset(x: isPressed ? -10 : 0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isHovered)
            
            // Book title below
            Text(story.title)
                .font(DesignTokens.Typography.caption.weight(.medium))
                .foregroundColor(DesignTokens.Colors.textPrimary)
                .lineLimit(1)
                .frame(width: 140)
                .padding(.top, 12)
        }
        .onTapGesture {
            isPressed = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                isPressed = false
                onTap()
            }
        }
        .onHover { hovering in
            isHovered = hovering
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
}

// MARK: - Book Open Animation View
struct BookOpenAnimationView: View {
    let story: Story
    @Environment(\.dismiss) private var dismiss
    
    @State private var openAmount: CGFloat = 0
    @State private var showContent = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                DesignTokens.Colors.warmBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Animated Book Opening
                    GeometryReader { geo in
                        ZStack {
                            // Left page
                            BookPage(
                                story: story,
                                isLeft: true,
                                openAmount: openAmount
                            )
                            .frame(width: geo.size.width * 0.45, height: geo.size.height * 0.7)
                            .offset(x: -geo.size.width * 0.22 * openAmount)
                            
                            // Right page
                            BookPage(
                                story: story,
                                isLeft: false,
                                openAmount: openAmount
                            )
                            .frame(width: geo.size.width * 0.45, height: geo.size.height * 0.7)
                            .offset(x: geo.size.width * 0.22 * openAmount)
                            
                            // Spine
                            Rectangle()
                                .fill(Color.brown.opacity(0.8))
                                .frame(width: 8, height: geo.size.height * 0.7)
                                .shadow(radius: 2)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .frame(height: 400)
                    
                    if showContent {
                        // Story info
                        VStack(spacing: 16) {
                            Text(story.title)
                                .font(DesignTokens.Typography.headlineLarge)
                                .foregroundColor(DesignTokens.Colors.textPrimary)
                            
                            Text(story.setting)
                                .font(DesignTokens.Typography.bodyLarge)
                                .foregroundColor(DesignTokens.Colors.textSecondary)
                            
                            Text("\(story.scenes.count) Seiten")
                                .font(DesignTokens.Typography.caption)
                                .foregroundColor(DesignTokens.Colors.textTertiary)
                            
                            // Read button
                            Button {
                                dismiss()
                                // Navigate to reader
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "book.open.fill")
                                    Text("Lesen")
                                }
                                .font(DesignTokens.Typography.headlineSmall)
                                .foregroundColor(.white)
                                .padding(.horizontal, 40)
                                .padding(.vertical, 16)
                                .background(
                                    Capsule()
                                        .fill(DesignTokens.Colors.primary)
                                        .shadow(color: DesignTokens.Colors.primary.opacity(0.4), radius: 12, x: 0, y: 6)
                                )
                            }
                            .buttonStyle(.plain)
                            .padding(.top, 20)
                        }
                        .padding()
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Schließen") {
                        dismiss()
                    }
                    .foregroundColor(DesignTokens.Colors.textSecondary)
                }
            }
        }
        .onAppear {
            // Animate book opening
            withAnimation(.easeInOut(duration: 0.8)) {
                openAmount = 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    showContent = true
                }
            }
        }
    }
}

// MARK: - Book Page
struct BookPage: View {
    let story: Story
    let isLeft: Bool
    let openAmount: CGFloat
    
    var body: some View {
        ZStack {
            // Page background
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.white)
                .shadow(
                    color: Color.black.opacity(0.15),
                    radius: 4,
                    x: isLeft ? -2 : 2,
                    y: 2
                )
            
            // Page content
            VStack {
                if isLeft {
                    // Left page - Title and info
                    VStack(spacing: 20) {
                        Image(systemName: iconForGenre(story.genre))
                            .font(.system(size: 48))
                            .foregroundColor(colorForGenre(story.genre))
                        
                        Text(story.title)
                            .font(.system(size: 20, weight: .bold, design: .serif))
                            .foregroundColor(DesignTokens.Colors.textPrimary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                        
                        Text(story.moral)
                            .font(.system(size: 14, weight: .medium, design: .serif))
                            .foregroundColor(DesignTokens.Colors.textSecondary)
                            .italic()
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 40)
                } else {
                    // Right page - Preview
                    VStack(spacing: 16) {
                        Text("Vorschau")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(DesignTokens.Colors.textTertiary)
                        
                        Text(story.scenes.first?.text ?? "")
                            .font(.system(size: 16, design: .serif))
                            .foregroundColor(DesignTokens.Colors.textPrimary)
                            .lineLimit(6)
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal, 20)
                        
                        Spacer()
                        
                        Text("...")
                            .font(.title2)
                            .foregroundColor(DesignTokens.Colors.textTertiary)
                    }
                    .padding(.vertical, 30)
                }
            }
            
            // Page lines effect
            VStack(spacing: 20) {
                ForEach(0..<12) { _ in
                    Rectangle()
                        .fill(Color.gray.opacity(0.05))
                        .frame(height: 1)
                }
            }
            .padding(.vertical, 40)
            .padding(.horizontal, 20)
        }
        .rotation3DEffect(
            .degrees(isLeft ? -5 * (1 - openAmount) : 5 * (1 - openAmount)),
            axis: (x: 0, y: 1, z: 0),
            anchor: isLeft ? .trailing : .leading
        )
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

#Preview {
    LibraryView()
        .environmentObject(SDAppStore())
}