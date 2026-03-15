import SwiftUI

// MARK: - Professional Children's Book Reader View
struct ReaderView: View {
    @EnvironmentObject var store: SDAppStore
    @Environment(\.dismiss) private var dismiss
    
    let story: StoryDTO
    
    @State private var currentPage: Int = 0
    @State private var musicOn = true
    @State private var sleepMinutes: Int = 0
    @State private var pageTransition: PageTransition = .none
    @State private var isAnimating = false
    
    // MARK: - Computed Properties
    private var currentScene: StoryScene? {
        guard !story.scenes.isEmpty else { return nil }
        return story.scenes[min(currentPage, story.scenes.count - 1)]
    }
    
    private var progressPercentage: Double {
        guard !story.scenes.isEmpty else { return 0 }
        return story.progressPercentage(for: currentPage)
    }
    
    private var canGoNext: Bool {
        currentPage < story.scenes.count - 1
    }
    
    private var canGoPrevious: Bool {
        currentPage > 0
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Background
            ProfessionalTheme.Gradients.warmBackground
                .ignoresSafeArea()
            
            if story.scenes.isEmpty {
                // Empty state
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 60))
                        .foregroundColor(.orange)
                    
                    Text("Keine Seiten vorhanden")
                        .font(.title2)
                        .foregroundColor(.primary)
                    
                    Button("Zurück") {
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else {
                VStack(spacing: 0) {
                    // Top Navigation Bar
                    topBar
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                    
                    // Main Content Area
                    ZStack {
                        // Illustration Area (70%)
                        illustrationArea
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                        // Navigation Arrows
                        navigationArrows
                    }
                    
                    // Text Card (30%)
                    textCard
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            if musicOn { store.audioManager.setEnabled(true) }
        }
        .onDisappear {
            store.audioManager.stop()
        }
        .onChange(of: musicOn) { _, newValue in
            store.audioManager.setEnabled(newValue)
        }
    }
    
    // MARK: - Top Bar
    private var topBar: some View {
        HStack(spacing: 16) {
            // Home Button
            Button(action: { dismiss() }) {
                Image(systemName: "house.fill")
                    .font(ProfessionalTheme.Typography.buttonFont)
                    .foregroundColor(ProfessionalTheme.Colors.textPrimary)
            }
            .accessibilityLabel("Zurück zur Bibliothek")
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 8)
                        .fill(ProfessionalTheme.Colors.cozyOrange.opacity(0.3))
                    
                    // Progress
                    RoundedRectangle(cornerRadius: 8)
                        .fill(ProfessionalTheme.Gradients.progressBar)
                        .frame(width: geometry.size.width * CGFloat(progressPercentage))
                }
            }
            .frame(height: 12)
            .accessibilityLabel("Fortschritt: Seite \(currentPage + 1) von \(story.totalPages)")
            
            // Music Button
            Button(action: { musicOn.toggle() }) {
                Image(systemName: musicOn ? "speaker.wave.2.fill" : "speaker.slash.fill")
                    .font(ProfessionalTheme.Typography.buttonFont)
                    .foregroundColor(ProfessionalTheme.Colors.textPrimary)
            }
            .accessibilityLabel(musicOn ? "Musik aus" : "Musik an")
            
            // Menu Button
            Menu {
                Button("Sleep Timer aus") {
                    sleepMinutes = 0
                    store.audioManager.cancelSleepTimer()
                }
                Button("Sleep Timer 10 min") {
                    sleepMinutes = 10
                    store.audioManager.setSleepTimer(minutes: 10)
                }
                Button("Sleep Timer 20 min") {
                    sleepMinutes = 20
                    store.audioManager.setSleepTimer(minutes: 20)
                }
                Button("Sleep Timer 30 min") {
                    sleepMinutes = 30
                    store.audioManager.setSleepTimer(minutes: 30)
                }
                Divider()
                Button("Zur Bibliothek") { dismiss() }
            } label: {
                Image(systemName: "ellipsis")
                    .font(ProfessionalTheme.Typography.buttonFont)
                    .foregroundColor(ProfessionalTheme.Colors.textPrimary)
            }
            .accessibilityLabel("Menü")
        }
        .frame(height: ProfessionalTheme.Layout.topBarHeight)
    }
    
    // MARK: - Illustration Area
    private var illustrationArea: some View {
        GeometryReader { geometry in
            ZStack {
                // Illustration Background
                let theme = SceneIllustrationTheme.forScene(currentPage)
                theme.gradient
                    .ignoresSafeArea()
                
                // Illustration Content
                VStack {
                    // Page Counter (Top Left)
                    HStack {
                        Text("\(currentPage + 1)/\(story.totalPages)")
                            .font(ProfessionalTheme.Typography.pageNumberFont)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(Color.black.opacity(0.4))
                            )
                            .padding(.leading, 20)
                            .padding(.top, 8)
                        
                        Spacer()
                    }
                    
                    Spacer()
                    
                    // Illustration Placeholder
                    illustrationPlaceholder(theme: theme)
                    
                    Spacer()
                }
            }
        }
        .transition(pageTransition.transition)
        .animation(.easeInOut(duration: 0.4), value: currentPage)
    }
    
    // MARK: - Illustration Placeholder
    private func illustrationPlaceholder(theme: SceneIllustrationTheme) -> some View {
        VStack(spacing: 20) {
            // Scene Icon
            Image(systemName: theme.iconName)
                .font(.system(size: 80, weight: .light))
                .foregroundColor(.white.opacity(0.9))
            
            // Scene Number
            if let scene = currentScene {
                Text("Szene \(scene.index)")
                    .font(ProfessionalTheme.Typography.captionFont)
                    .foregroundColor(.white.opacity(0.8))
                
                // Illustration Prompt Preview (for development)
                if !scene.imagePrompt.isEmpty {
                    Text(scene.imagePrompt.prefix(60) + "...")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .lineLimit(2)
                }
            }
        }
        .padding(40)
    }
    
    // MARK: - Navigation Arrows
    private var navigationArrows: some View {
        GeometryReader { geometry in
            HStack {
                // Previous Button
                if canGoPrevious {
                    Button(action: goToPreviousPage) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 24, weight: .semibold))
                    }
                    .navButtonStyle()
                    .padding(.leading, 16)
                    .accessibilityLabel("Vorherige Seite")
                } else {
                    Spacer()
                        .frame(width: ProfessionalTheme.Layout.navButtonSize + 16)
                }
                
                Spacer()
                
                // Next Button
                if canGoNext {
                    Button(action: goToNextPage) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 24, weight: .semibold))
                    }
                    .navButtonStyle()
                    .padding(.trailing, 16)
                    .accessibilityLabel("Nächste Seite")
                } else {
                    Spacer()
                        .frame(width: ProfessionalTheme.Layout.navButtonSize + 16)
                }
            }
            .frame(height: geometry.size.height * ProfessionalTheme.Layout.illustrationRatio)
        }
    }
    
    // MARK: - Text Card
    private var textCard: some View {
        VStack(spacing: 0) {
            // Drag Handle
            RoundedRectangle(cornerRadius: 2.5)
                .fill(ProfessionalTheme.Colors.textSecondary.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, 12)
                .padding(.bottom, 8)
            
            // Story Text
            ScrollView {
                if let scene = currentScene {
                    Text(scene.text)
                        .font(ProfessionalTheme.Typography.storyTextFont)
                        .foregroundColor(ProfessionalTheme.Colors.textPrimary)
                        .lineSpacing(8)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            
            // Bottom Indicator Dots
            pageIndicatorDots
                .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity)
        .frame(height: UIScreen.main.bounds.height * ProfessionalTheme.Layout.textCardRatio)
        .storyCardStyle()
        .transition(.move(edge: .bottom))
    }
    
    // MARK: - Page Indicator Dots
    private var pageIndicatorDots: some View {
        HStack(spacing: 8) {
            ForEach(0..<min(story.totalPages, 20), id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? 
                          ProfessionalTheme.Colors.accent : 
                          ProfessionalTheme.Colors.cozyOrange.opacity(0.4))
                    .frame(width: index == currentPage ? 10 : 6, 
                           height: index == currentPage ? 10 : 6)
                    .animation(.easeInOut(duration: 0.2), value: currentPage)
            }
        }
    }
    
    // MARK: - Navigation Actions
    private func goToNextPage() {
        guard canGoNext && !isAnimating else { return }
        isAnimating = true
        pageTransition = .next
        
        withAnimation(.easeInOut(duration: 0.4)) {
            currentPage += 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            isAnimating = false
            pageTransition = .none
        }
    }
    
    private func goToPreviousPage() {
        guard canGoPrevious && !isAnimating else { return }
        isAnimating = true
        pageTransition = .previous
        
        withAnimation(.easeInOut(duration: 0.4)) {
            currentPage -= 1
        }

        store.audioManager.playPageTurn()
        store.audioManager.playForScene(mood: story.scenes[max(currentPage, 0)].bgmMood)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            isAnimating = false
            pageTransition = .none
        }
    }
}

// MARK: - Page Transition
enum PageTransition {
    case none
    case next
    case previous
    
    var transition: AnyTransition {
        switch self {
        case .none:
            return .identity
        case .next:
            return .asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            )
        case .previous:
            return .asymmetric(
                insertion: .move(edge: .leading).combined(with: .opacity),
                removal: .move(edge: .trailing).combined(with: .opacity)
            )
        }
    }
}

// MARK: - Preview
#Preview {
    let sampleStory = StoryDTO(
        title: "Die Traumkatze Klara",
        language: .de,
        genre: .bedtime,
        setting: "Kinderzimmer und Traumwelt",
        moral: "Mut und Freundschaft überwinden alle Ängste",
        children: [],
        scenes: [
            StoryScene(
                index: 1,
                text: "Als die Nacht näher rückte und die Sterne am Himmel erschienen, schlich eine kleine, silberne Katze durch das offene Fenster von Emmas Zimmer.",
                imagePrompt: "Eine kleine silberne Katze mit leuchtenden Augen schleicht durch ein offenes Fenster in ein gemütliches Kinderzimmer bei Mondlicht",
                bgmMood: "peaceful",
                illustrationTheme: "bedroom"
            ),
            StoryScene(
                index: 2,
                text: "Die Katze hieß Klara und sie war keine gewöhnliche Katze. Sie war eine Traumkatze, die jeden Abend zu Kindern kam, die ihre Hilfe brauchten.",
                imagePrompt: "Nahaufnahme der silbernen Traumkatze Klara mit magisch leuchtenden Augen",
                bgmMood: "magical",
                illustrationTheme: "magic"
            ),
            StoryScene(
                index: 3,
                text: "Emma lag wach im Bett und seufzte. Sie hatte Angst vor der Dunkelheit und konnte einfach nicht einschlafen.",
                imagePrompt: "Ein kleines Mädchen namens Emma liegt in einem gemütlichen Bett",
                bgmMood: "melancholic",
                illustrationTheme: "bedroom"
            )
        ]
    )
    
    NavigationStack {
        ReaderView(story: sampleStory)
            .environmentObject(SDAppStore())
    }
}
