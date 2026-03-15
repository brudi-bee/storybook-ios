import SwiftUI
import UIKit

struct HomeView: View {
    @EnvironmentObject var store: SDAppStore
    @State private var selectedStory: Story?
    @State private var showingLibrary = false
    @State private var isRefreshing = false
    @State private var showNeedsChildAlert = false
    @State private var heroAnimation = false
    
    // Haptic feedback
    private let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    private let selectionFeedback = UISelectionFeedbackGenerator()
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Animated Background
                MeshGradientBackground()
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Hero Section
                        HeroSection(
                            childName: store.children.first?.name,
                            hasChildren: !store.children.isEmpty,
                            onNeedsChild: { showNeedsChildAlert = true }
                        )
                        .padding(.top, 20)
                        
                        // Neueste Geschichten (Top 3 from library)
                        LatestStoriesSection(
                            stories: Array(store.stories.prefix(3)),
                            onStoryTap: { story in
                                impactFeedback.impactOccurred()
                                selectedStory = story
                            },
                            onSeeAll: { showingLibrary = true }
                        )
                        .padding(.top, 32)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .sheet(item: $selectedStory) { story in
                ReaderView(story: convertToDTO(story))
            }
            .navigationDestination(isPresented: $showingLibrary) {
                LibraryView()
            }
            .alert("Kinderprofil benötigt", isPresented: $showNeedsChildAlert) {
                Button("Zum Profil", role: .none) {
                    // Could trigger tab switch here
                }
                Button("Abbrechen", role: .cancel) { }
            } message: {
                Text("Lege im Tab 'Kinder' ein Profil an, um personalisierte Geschichten zu erhalten.")
            }
        }
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

// MARK: - Animated Background
struct MeshGradientBackground: View {
    @State private var animate = false
    
    var body: some View {
        Group {
            if #available(iOS 18.0, *) {
                // iOS 18+: Use MeshGradient
                TimelineView(.animation(minimumInterval: 0.1, paused: false)) { _ in
                    MeshGradient(
                        width: 3,
                        height: 3,
                        points: [
                            .init(x: 0, y: 0), .init(x: 0.5, y: animate ? 0.2 : 0), .init(x: 1, y: 0),
                            .init(x: animate ? 0.2 : 0, y: 0.5), .init(x: 0.5, y: 0.5), .init(x: animate ? 0.8 : 1, y: 0.5),
                            .init(x: 0, y: 1), .init(x: 0.5, y: animate ? 0.8 : 1), .init(x: 1, y: 1)
                        ],
                        colors: [
                            Color(red: 0.95, green: 0.90, blue: 0.98),
                            Color(red: 0.90, green: 0.85, blue: 0.95),
                            Color(red: 0.98, green: 0.92, blue: 0.90),
                            Color(red: 0.88, green: 0.92, blue: 0.98),
                            Color(red: 0.95, green: 0.93, blue: 0.96),
                            Color(red: 0.92, green: 0.88, blue: 0.95),
                            Color(red: 0.90, green: 0.92, blue: 0.96),
                            Color(red: 0.96, green: 0.90, blue: 0.92),
                            Color(red: 0.94, green: 0.94, blue: 0.98)
                        ]
                    )
                }
            } else {
                // iOS 17: Fallback to LinearGradient
                LinearGradient(
                    colors: [
                        Color(red: 0.95, green: 0.90, blue: 0.98),
                        Color(red: 0.90, green: 0.85, blue: 0.95),
                        Color(red: 0.98, green: 0.92, blue: 0.90),
                        Color(red: 0.88, green: 0.92, blue: 0.98)
                    ],
                    startPoint: animate ? .topLeading : .bottomLeading,
                    endPoint: animate ? .bottomTrailing : .topTrailing
                )
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                animate.toggle()
            }
        }
    }
}

// MARK: - Hero Section
struct HeroSection: View {
    let childName: String?
    let hasChildren: Bool
    let onNeedsChild: () -> Void
    
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            // Animated Logo
            ZStack {
                // Outer glow rings
                ForEach(0..<3) { i in
                    Circle()
                        .stroke(
                            DesignTokens.Colors.primary.opacity(0.3 - Double(i) * 0.08),
                            lineWidth: 2
                        )
                        .frame(width: 120 + CGFloat(i) * 20, height: 120 + CGFloat(i) * 20)
                        .scaleEffect(isAnimating ? 1.1 : 1.0)
                        .opacity(isAnimating ? 0.5 : 1.0)
                        .animation(
                            .easeInOut(duration: 2).delay(Double(i) * 0.2).repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                }
                
                // Main circle
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [DesignTokens.Colors.primary, DesignTokens.Colors.primaryLight],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .shadow(color: DesignTokens.Colors.primary.opacity(0.4), radius: 20, x: 0, y: 10)
                
                // Icon
                Image(systemName: "book.fill")
                    .font(.system(size: 44, weight: .medium))
                    .foregroundStyle(.white)
                    .shadow(radius: 4)
            }
            .onAppear { isAnimating = true }
            
            // Title
            VStack(spacing: DesignTokens.Spacing.sm) {
                Text("Magische Geschichten")
                    .font(DesignTokens.Typography.displayMedium)
                    .foregroundColor(DesignTokens.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                
                if let name = childName {
                    Text("Für \(name)")
                        .font(DesignTokens.Typography.headlineMedium)
                        .foregroundColor(DesignTokens.Colors.primary)
                } else {
                    Text("Für kleine Abenteurer")
                        .font(DesignTokens.Typography.headlineMedium)
                        .foregroundColor(DesignTokens.Colors.textSecondary)
                }
            }
            
            // Status Badge
            if !hasChildren {
                Button(action: onNeedsChild) {
                    HStack(spacing: 8) {
                        Image(systemName: "person.badge.plus")
                        Text("Profil anlegen")
                    }
                    .font(DesignTokens.Typography.bodyMedium.weight(.semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(DesignTokens.Colors.warning)
                            .shadow(color: DesignTokens.Colors.warning.opacity(0.3), radius: 8, x: 0, y: 4)
                    )
                }
                .buttonStyle(.plain)
            } else {
                Label {
                    Text("Neue Geschichte diese Woche")
                        .font(DesignTokens.Typography.caption.weight(.semibold))
                } icon: {
                    Image(systemName: "sparkles")
                        .foregroundColor(DesignTokens.Colors.warmAccent)
                }
                .foregroundColor(DesignTokens.Colors.textSecondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.6))
                )
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.lg)
    }
}

// MARK: - Latest Stories Section
struct LatestStoriesSection: View {
    let stories: [Story]
    let onStoryTap: (Story) -> Void
    let onSeeAll: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            // Header
            HStack {
                Text("Neueste Geschichten")
                    .font(DesignTokens.Typography.headlineLarge)
                    .foregroundColor(DesignTokens.Colors.textPrimary)
                
                Spacer()
                
                Button(action: onSeeAll) {
                    HStack(spacing: 4) {
                        Text("Alle")
                            .font(DesignTokens.Typography.bodyMedium.weight(.semibold))
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    .foregroundColor(DesignTokens.Colors.primary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, DesignTokens.Spacing.lg)
            
            if stories.isEmpty {
                // Empty state
                VStack(spacing: DesignTokens.Spacing.md) {
                    Image(systemName: "book.closed")
                        .font(.system(size: 48))
                        .foregroundColor(DesignTokens.Colors.textTertiary)
                    
                    Text("Noch keine Geschichten")
                        .font(DesignTokens.Typography.bodyLarge)
                        .foregroundColor(DesignTokens.Colors.textSecondary)
                }
                .frame(maxWidth: .infinity, minHeight: 150)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.large)
                        .fill(Color.white.opacity(0.5))
                )
                .padding(.horizontal, DesignTokens.Spacing.lg)
            } else {
                // Horizontal Scroll
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DesignTokens.Spacing.md) {
                        ForEach(stories) { story in
                            Button {
                                onStoryTap(story)
                            } label: {
                                ModernStoryCardFromLibrary(story: story)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, DesignTokens.Spacing.lg)
                }
            }
        }
    }
}

// MARK: - Modern Story Card from Library
struct ModernStoryCardFromLibrary: View {
    let story: Story
    @State private var isPressed = false
    
    private var gradientColors: [Color] {
        switch story.genre {
        case .adventure: return [.orange, .red]
        case .friendship: return [.green, .teal]
        case .fantasy: return [.purple, .pink]
        case .animals: return [.brown, .orange]
        case .bedtime: return [.blue, .indigo]
        }
    }
    
    private var iconName: String {
        switch story.genre {
        case .adventure: return "map.fill"
        case .friendship: return "heart.fill"
        case .fantasy: return "sparkles"
        case .animals: return "pawprint.fill"
        case .bedtime: return "moon.fill"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image Area
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.large)
                    .fill(
                        LinearGradient(
                            colors: gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 260, height: 170)
                
                // Pattern overlay
                Image(systemName: iconName)
                    .font(.system(size: 80, weight: .ultraLight))
                    .foregroundStyle(.white.opacity(0.15))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                
                // Genre Badge
                Text(story.genre.displayName)
                    .font(DesignTokens.Typography.captionSmall.weight(.semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.3))
                    )
                    .padding(12)
            }
            
            // Text Area
            VStack(alignment: .leading, spacing: 4) {
                Text(story.title)
                    .font(DesignTokens.Typography.headlineSmall)
                    .foregroundColor(DesignTokens.Colors.textPrimary)
                    .lineLimit(1)
                
                Text(story.setting)
                    .font(DesignTokens.Typography.bodySmall)
                    .foregroundColor(DesignTokens.Colors.textSecondary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(width: 260, alignment: .leading)
            .background(Color.white)
        }
        .background(Color.white)
        .cornerRadius(DesignTokens.CornerRadius.large)
        .shadow(
            color: Color.black.opacity(isPressed ? 0.15 : 0.08),
            radius: isPressed ? 12 : 8,
            x: 0,
            y: isPressed ? 8 : 4
        )
        .scaleEffect(1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
    }
}

// MARK: - Library Preview Section
struct LibraryPreviewSection: View {
    let stories: [Story]
    let totalCount: Int
    let onStoryTap: (Story) -> Void
    let onSeeAll: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            // Header
            HStack {
                Text("Bibliothek")
                    .font(DesignTokens.Typography.headlineLarge)
                    .foregroundColor(DesignTokens.Colors.textPrimary)
                
                Spacer()
                
                if totalCount > 0 {
                    Text("\(totalCount) Geschichten")
                        .font(DesignTokens.Typography.caption)
                        .foregroundColor(DesignTokens.Colors.textTertiary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.6))
                        )
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.lg)
            
            if stories.isEmpty {
                // Empty State
                VStack(spacing: DesignTokens.Spacing.md) {
                    Image(systemName: "book.closed")
                        .font(.system(size: 48))
                        .foregroundColor(DesignTokens.Colors.textTertiary)
                    
                    Text("Noch keine Geschichten")
                        .font(DesignTokens.Typography.bodyLarge)
                        .foregroundColor(DesignTokens.Colors.textSecondary)
                }
                .frame(maxWidth: .infinity, minHeight: 150)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.large)
                        .fill(Color.white.opacity(0.5))
                )
                .padding(.horizontal, DesignTokens.Spacing.lg)
            } else {
                // Grid
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: DesignTokens.Spacing.md),
                        GridItem(.flexible(), spacing: DesignTokens.Spacing.md)
                    ],
                    spacing: DesignTokens.Spacing.md
                ) {
                    ForEach(stories) { story in
                        CompactLibraryCard(story: story)
                            .onTapGesture {
                                onStoryTap(story)
                            }
                    }
                }
                .padding(.horizontal, DesignTokens.Spacing.lg)
                
                // See All Button
                if totalCount > stories.count {
                    Button(action: onSeeAll) {
                        HStack(spacing: 8) {
                            Text("Alle anzeigen")
                                .font(DesignTokens.Typography.bodyMedium.weight(.semibold))
                            Image(systemName: "arrow.right")
                                .font(.caption.weight(.semibold))
                        }
                        .foregroundColor(DesignTokens.Colors.primary)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                        )
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, DesignTokens.Spacing.md)
                }
            }
        }
    }
}

// MARK: - Compact Library Card
struct CompactLibraryCard: View {
    let story: Story
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.medium)
                    .fill(
                        LinearGradient(
                            colors: gradientForGenre(story.genre),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                
                Image(systemName: iconForGenre(story.genre))
                    .font(.system(size: 24))
                    .foregroundStyle(.white)
            }
            
            // Text
            VStack(alignment: .leading, spacing: 4) {
                Text(story.title)
                    .font(DesignTokens.Typography.bodyLarge.weight(.semibold))
                    .foregroundColor(DesignTokens.Colors.textPrimary)
                    .lineLimit(1)
                
                Text(story.setting)
                    .font(DesignTokens.Typography.bodySmall)
                    .foregroundColor(DesignTokens.Colors.textSecondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(DesignTokens.Colors.textTertiary)
        }
        .padding(DesignTokens.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.large)
                .fill(Color.white)
                .shadow(
                    color: Color.black.opacity(isPressed ? 0.12 : 0.06),
                    radius: isPressed ? 10 : 6,
                    x: 0,
                    y: isPressed ? 6 : 3
                )
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.8), value: isPressed)
        .onPressingChanged { pressing in
            isPressed = pressing
        }
    }
    
    private func gradientForGenre(_ genre: StoryGenre) -> [Color] {
        switch genre {
        case .adventure: return [.orange, .red]
        case .friendship: return [.green, .teal]
        case .fantasy: return [.purple, .pink]
        case .animals: return [.brown, .orange]
        case .bedtime: return [.blue, .indigo]
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

// MARK: - Preview
#Preview {
    HomeView()
        .environmentObject(SDAppStore())
}
