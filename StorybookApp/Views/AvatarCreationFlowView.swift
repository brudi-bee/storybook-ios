import SwiftUI
import SwiftData

// MARK: - Avatar Creation Flow View
struct AvatarCreationFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let child: ChildProfile
    let onComplete: () -> Void
    
    @State private var currentStep: AvatarCreationStep = .gender
    @State private var configuration = AvatarConfiguration()
    @State private var selectedGender: GenderSelection = .neutral
    @State private var isGenerating = false
    @State private var generationError: String?
    @State private var showPreview = false
    
    private let avatarService: AvatarGenerationService
    
    init(child: ChildProfile, onComplete: @escaping () -> Void) {
        self.child = child
        self.onComplete = onComplete
        self.avatarService = AvatarServiceFactory.createMockService()
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Progress indicator
                ProgressView(value: Double(currentStep.rawValue), total: Double(AvatarCreationStep.allCases.count - 1))
                    .padding(.horizontal)
                    .padding(.top)
                
                // Step content
                ScrollView {
                    VStack(spacing: 24) {
                        stepHeader
                        stepContent
                    }
                    .padding()
                }
                
                // Navigation buttons
                navigationButtons
                    .padding()
            }
            .navigationTitle("Avatar erstellen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showPreview) {
                AvatarPreviewSheet(
                    configuration: configuration,
                    name: child.name,
                    gender: selectedGender,
                    onConfirm: saveAvatar,
                    onRegenerate: { showPreview = false }
                )
            }
        }
    }
    
    // MARK: - Step Header
    private var stepHeader: some View {
        VStack(spacing: 8) {
            Text(currentStep.title)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(currentStep.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Step Content
    @ViewBuilder
    private var stepContent: some View {
        switch currentStep {
        case .gender:
            GenderSelectionStep(selection: $selectedGender)
        case .style:
            StyleSelectionStep(selection: $configuration.style)
        case .hairColor:
            HairColorSelectionStep(selection: $configuration.hairColor)
        case .skinTone:
            SkinToneSelectionStep(selection: $configuration.skinTone)
        case .eyeColor:
            EyeColorSelectionStep(selection: $configuration.eyeColor)
        case .clothing:
            ClothingColorStep(color: $configuration.clothingColor)
        case .preview:
            AvatarPreviewPlaceholder(configuration: configuration, name: child.name)
        }
    }
    
    // MARK: - Navigation Buttons
    private var navigationButtons: some View {
        HStack {
            if currentStep != .gender {
                Button("Zurück") {
                    withAnimation {
                        currentStep = currentStep.previous
                    }
                }
                .buttonStyle(.bordered)
            }
            
            Spacer()
            
            if currentStep == .preview {
                Button(action: generateAvatar) {
                    if isGenerating {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Text("Avatar erstellen")
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isGenerating)
            } else {
                Button("Weiter") {
                    withAnimation {
                        currentStep = currentStep.next
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
    
    // MARK: - Actions
    private func generateAvatar() {
        isGenerating = true
        generationError = nil
        
        Task {
            do {
                let result = try await avatarService.generateAvatar(
                    for: configuration,
                    name: child.name,
                    gender: selectedGender
                )
                
                await MainActor.run {
                    child.setAvatarImage(result.imageData)
                    child.updateAvatarConfiguration(configuration)
                    child.genderRaw = selectedGender.toChildGender.rawValue
                    showPreview = true
                    isGenerating = false
                }
            } catch {
                await MainActor.run {
                    generationError = error.localizedDescription
                    isGenerating = false
                }
            }
        }
    }
    
    private func saveAvatar() {
        child.updateAvatarConfiguration(configuration)
        child.genderRaw = selectedGender.toChildGender.rawValue
        
        do {
            try modelContext.save()
            onComplete()
            dismiss()
        } catch {
            print("Failed to save avatar: \(error)")
        }
    }
}

// MARK: - Avatar Creation Steps
enum AvatarCreationStep: Int, CaseIterable {
    case gender = 0
    case style = 1
    case hairColor = 2
    case skinTone = 3
    case eyeColor = 4
    case clothing = 5
    case preview = 6
    
    var title: String {
        switch self {
        case .gender: return "Wer bist du?"
        case .style: return "Wähle einen Stil"
        case .hairColor: return "Haarfarbe"
        case .skinTone: return "Hautton"
        case .eyeColor: return "Augenfarbe"
        case .clothing: return "Lieblingsfarbe"
        case .preview: return "Fast fertig!"
        }
    }
    
    var description: String {
        switch self {
        case .gender: return "Wähle, wie dein Charakter aussehen soll"
        case .style: return "Welcher Stil gefällt dir am besten?"
        case .hairColor: return "Welche Haarfarbe hat dein Charakter?"
        case .skinTone: return "Wähle den Hautton deines Charakters"
        case .eyeColor: return "Welche Augenfarbe soll dein Charakter haben?"
        case .clothing: return "Wähle deine Lieblingsfarbe für die Kleidung"
        case .preview: return "Überprüfe deine Auswahl"
        }
    }
    
    var next: AvatarCreationStep {
        AvatarCreationStep(rawValue: min(rawValue + 1, AvatarCreationStep.allCases.count - 1)) ?? .preview
    }
    
    var previous: AvatarCreationStep {
        AvatarCreationStep(rawValue: max(rawValue - 1, 0)) ?? .gender
    }
}

// MARK: - Gender Selection Step
struct GenderSelectionStep: View {
    @Binding var selection: GenderSelection
    
    var body: some View {
        VStack(spacing: 20) {
            ForEach(GenderSelection.allCases) { gender in
                GenderCard(gender: gender, isSelected: selection == gender) {
                    withAnimation(.spring()) {
                        selection = gender
                    }
                }
            }
        }
    }
}

struct GenderCard: View {
    let gender: GenderSelection
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Emoji icon
                Text(gender.emoji)
                    .font(.system(size: 50))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(gender.displayName)
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Text("Tap to select")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Selection indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(isSelected ? .white : .secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: isSelected ? gender.gradient : [.gray.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .foregroundStyle(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(), value: isSelected)
    }
}

// MARK: - Style Selection Step
struct StyleSelectionStep: View {
    @Binding var selection: AvatarStyle
    
    let columns = [GridItem(.adaptive(minimum: 150))]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(AvatarStyle.allCases) { style in
                StyleCard(style: style, isSelected: selection == style) {
                    selection = style
                }
            }
        }
    }
}

struct StyleCard: View {
    let style: AvatarStyle
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: style.icon)
                    .font(.system(size: 40))
                    .frame(height: 60)
                
                Text(style.displayName)
                    .font(.headline)
                
                Text(style.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 150)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.accentColor.opacity(0.1) : Color.gray.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Hair Color Selection Step
struct HairColorSelectionStep: View {
    @Binding var selection: HairColor
    
    let columns = [GridItem(.adaptive(minimum: 100))]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(HairColor.allCases) { color in
                ColorSelectionCard(
                    title: color.displayName,
                    color: color.color,
                    isSelected: selection == color
                ) {
                    selection = color
                }
            }
        }
    }
}

// MARK: - Skin Tone Selection Step
struct SkinToneSelectionStep: View {
    @Binding var selection: SkinTone
    
    let columns = [GridItem(.adaptive(minimum: 100))]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(SkinTone.allCases) { tone in
                ColorSelectionCard(
                    title: tone.displayName,
                    color: tone.color,
                    isSelected: selection == tone
                ) {
                    selection = tone
                }
            }
        }
    }
}

// MARK: - Eye Color Selection Step
struct EyeColorSelectionStep: View {
    @Binding var selection: EyeColor
    
    let columns = [GridItem(.adaptive(minimum: 100))]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(EyeColor.allCases) { color in
                ColorSelectionCard(
                    title: color.displayName,
                    color: color.color,
                    isSelected: selection == color
                ) {
                    selection = color
                }
            }
        }
    }
}

// MARK: - Color Selection Card
struct ColorSelectionCard: View {
    let title: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Circle()
                    .fill(color)
                    .frame(width: 60, height: 60)
                    .overlay(
                        Circle()
                            .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 3)
                    )
                    .shadow(radius: isSelected ? 4 : 0)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .padding()
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Clothing Color Step
struct ClothingColorStep: View {
    @Binding var color: CodableColor
    
    let presetColors: [Color] = [
        .red, .orange, .yellow, .green, .blue, .purple, .pink,
        .cyan, .mint, .indigo, .brown, .gray
    ]
    
    var body: some View {
        VStack(spacing: 24) {
            // Color preview
            RoundedRectangle(cornerRadius: 20)
                .fill(color.color)
                .frame(height: 120)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
            
            // Preset colors
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 12) {
                ForEach(presetColors, id: \.self) { preset in
                    Button(action: { color = CodableColor(color: preset) }) {
                        Circle()
                            .fill(preset)
                            .frame(width: 50, height: 50)
                            .overlay(
                                Circle()
                                    .stroke(color.color == preset ? Color.white : Color.clear, lineWidth: 3)
                                    .padding(2)
                            )
                            .overlay(
                                Circle()
                                    .stroke(color.color == preset ? Color.accentColor : Color.clear, lineWidth: 2)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

// MARK: - Avatar Preview Placeholder
struct AvatarPreviewPlaceholder: View {
    let configuration: AvatarConfiguration
    let name: String
    
    var body: some View {
        VStack(spacing: 20) {
            // Avatar preview circle
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [configuration.clothingColor.color, configuration.skinTone.color],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 200, height: 200)
                
                VStack {
                    Text(configuration.style.emoji)
                        .font(.system(size: 80))
                    Text(name.prefix(1).uppercased())
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            
            // Configuration summary
            VStack(alignment: .leading, spacing: 12) {
                SummaryRow(icon: "paintbrush.fill", title: "Stil", value: configuration.style.displayName)
                SummaryRow(icon: "person.fill", title: "Haarfarbe", value: configuration.hairColor.displayName)
                SummaryRow(icon: "hand.thumbsup.fill", title: "Hautton", value: configuration.skinTone.displayName)
                SummaryRow(icon: "eye.fill", title: "Augenfarbe", value: configuration.eyeColor.displayName)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

struct SummaryRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
                .frame(width: 24)
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

// MARK: - Avatar Preview Sheet
struct AvatarPreviewSheet: View {
    let configuration: AvatarConfiguration
    let name: String
    let gender: GenderSelection
    let onConfirm: () -> Void
    let onRegenerate: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                
                AvatarPreviewPlaceholder(configuration: configuration, name: name)
                
                Spacer()
                
                VStack(spacing: 12) {
                    Button("Speichern", action: onConfirm)
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    
                    Button("Neu generieren", action: onRegenerate)
                        .buttonStyle(.bordered)
                }
                .padding()
            }
            .navigationTitle("Dein Avatar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Schließen") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Avatar Style Extension
extension AvatarStyle {
    var emoji: String {
        switch self {
        case .animalRabbit: return "🐰"
        case .animalBear: return "🐻"
        case .animalFox: return "🦊"
        case .cartoon: return "😊"
        case .realistic: return "👤"
        }
    }
}