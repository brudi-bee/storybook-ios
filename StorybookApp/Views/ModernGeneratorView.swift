import SwiftUI

struct ModernGeneratorView: View {
    @EnvironmentObject var store: SDAppStore
    @State private var showingSettings = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Subtle background
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header Card
                        HeaderCard(
                            title: "Neue Geschichte",
                            subtitle: "Erstelle ein magisches Abenteuer"
                        )
                        
                        // Settings Form
                        VStack(spacing: 16) {
                            // Language & Genre
                            HStack(spacing: 12) {
                                SettingCard(icon: "globe", title: "Sprache") {
                                    Picker("", selection: $store.request.language) {
                                        ForEach(StoryLanguage.allCases) { lang in
                                            Text(lang.displayName).tag(lang)
                                        }
                                    }
                                    .pickerStyle(.segmented)
                                }
                                
                                SettingCard(icon: "textformat", title: "Genre") {
                                    Picker("", selection: $store.request.genre) {
                                        ForEach(StoryGenre.allCases) { genre in
                                            Text(genre.displayName).tag(genre)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                }
                            }
                            
                            // Scene Count Slider
                            SettingCard(icon: "number", title: "Szenen: \(store.request.sceneCount)") {
                                Slider(value: .init(
                                    get: { Double(store.request.sceneCount) },
                                    set: { store.request.sceneCount = Int($0) }
                                ), in: 4...10, step: 1)
                                .tint(.purple)
                            }
                            
                            // Setting Input
                            SettingCard(icon: "mappin.and.ellipse", title: "Setting") {
                                TextField("z.B. Sternenwald", text: $store.request.setting)
                                    .textFieldStyle(.roundedBorder)
                            }
                            
                            // Moral Input
                            SettingCard(icon: "heart.fill", title: "Moral / Botschaft") {
                                TextField("z.B. Mut und Freundschaft", text: $store.request.moral)
                                    .textFieldStyle(.roundedBorder)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Generate Button
                        Button {
                            Task { await store.generateStory() }
                        } label: {
                            HStack {
                                if store.isGenerating {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Image(systemName: "wand.and.stars")
                                }
                                Text(store.isGenerating ? "Erstelle..." : "Geschichte erstellen")
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        LinearGradient(
                                            colors: [.purple, .blue],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .shadow(color: .purple.opacity(0.3), radius: 8, x: 0, y: 4)
                            )
                        }
                        .disabled(store.children.isEmpty || store.isGenerating || !(store.settings?.canGenerateNewStory() ?? true))
                        .padding(.horizontal)
                        
                        // Daily Limit Warning
                        if !(store.settings?.canGenerateNewStory() ?? true) {
                            Label("Tageslimit erreicht", systemImage: "exclamationmark.triangle")
                                .foregroundColor(.orange)
                                .font(.caption)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Generator")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
        }
    }
}

// MARK: - Components

struct HeaderCard: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.title2.bold())
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.linearGradient(
                            colors: [.purple.opacity(0.3), .blue.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ), lineWidth: 1)
                )
        )
        .padding(.horizontal)
    }
}

struct SettingCard<Content: View>: View {
    let icon: String
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(.purple)
                Text(title)
                    .font(.subheadline.weight(.medium))
                Spacer()
            }
            content
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.background)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

#Preview {
    ModernGeneratorView()
        .environmentObject(SDAppStore())
}
