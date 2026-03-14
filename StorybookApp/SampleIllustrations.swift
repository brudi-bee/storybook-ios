import SwiftUI

// MARK: - Sample Illustrations for Story Scenes
// Gradient placeholders with different colors/themes per scene
// Character consistency: Cat character (Klara) represented through icons

struct SampleIllustrations {
    
    // MARK: - Scene Illustration Data
    static let sceneIllustrations: [SceneIllustration] = [
        // Scene 1: Bedroom - Night arrival
        SceneIllustration(
            sceneIndex: 1,
            gradientColors: ["#FFE4C4", "#DEB887", "#8B7355"],
            iconName: "bed.double.fill",
            overlayText: "Klaras Ankunft"
        ),
        
        // Scene 2: Magic - Klara revealed
        SceneIllustration(
            sceneIndex: 2,
            gradientColors: ["#667eea", "#764ba2", "#f093fb"],
            iconName: "sparkles",
            overlayText: "Die Traumkatze"
        ),
        
        // Scene 3: Bedroom - Emma worried
        SceneIllustration(
            sceneIndex: 3,
            gradientColors: ["#2C3E50", "#4A6741", "#8B7355"],
            iconName: "moon.fill",
            overlayText: "Emma kann nicht schlafen"
        ),
        
        // Scene 4: Cozy - First meeting
        SceneIllustration(
            sceneIndex: 4,
            gradientColors: ["#D4A574", "#FDF6E3", "#E67E22"],
            iconName: "hand.raised.fill",
            overlayText: "Ein magisches Treffen"
        ),
        
        // Scene 5: Cozy - Petting Klara
        SceneIllustration(
            sceneIndex: 5,
            gradientColors: ["#FAD961", "#F76B1C", "#FFE4C4"],
            iconName: "heart.fill",
            overlayText: "Wohlige Wärme"
        ),
        
        // Scene 6: Stars - Room transforms
        SceneIllustration(
            sceneIndex: 6,
            gradientColors: ["#0f0c29", "#302b63", "#24243e"],
            iconName: "wand.and.stars",
            overlayText: "Die Verwandlung"
        ),
        
        // Scene 7: DreamSky - Dream world
        SceneIllustration(
            sceneIndex: 7,
            gradientColors: ["#667eea", "#764ba2", "#f093fb"],
            iconName: "cloud.moon.fill",
            overlayText: "Die Traumwelt"
        ),
        
        // Scene 8: Cloud - Protection
        SceneIllustration(
            sceneIndex: 8,
            gradientColors: ["#E0E7FF", "#C7D2FE", "#A5B4FC"],
            iconName: "shield.fill",
            overlayText: "Schutz der Träume"
        ),
        
        // Scene 9: Stars - Sad star
        SceneIllustration(
            sceneIndex: 9,
            gradientColors: ["#1a1a2e", "#16213e", "#0f3460"],
            iconName: "star.slash.fill",
            overlayText: "Der traurige Stern"
        ),
        
        // Scene 10: Night - Star losing light
        SceneIllustration(
            sceneIndex: 10,
            gradientColors: ["#0f2027", "#203a43", "#2c5364"],
            iconName: "exclamationmark.triangle.fill",
            overlayText: "Das Licht erlischt"
        ),
        
        // Scene 11: Magic - Emma helps
        SceneIllustration(
            sceneIndex: 11,
            gradientColors: ["#f093fb", "#f5576c", "#ffecd2"],
            iconName: "heart.circle.fill",
            overlayText: "Erinnerungen sammeln"
        ),
        
        // Scene 12: Cozy - Believe in yourself
        SceneIllustration(
            sceneIndex: 12,
            gradientColors: ["#FFE4C4", "#D4A574", "#8B5A2B"],
            iconName: "lightbulb.fill",
            overlayText: "Glaube an dich"
        ),
        
        // Scene 13: Sunrise - Beautiful memory
        SceneIllustration(
            sceneIndex: 13,
            gradientColors: ["#FF6B6B", "#FFE66D", "#FF8E53"],
            iconName: "person.2.fill",
            overlayText: "Schöne Erinnerung"
        ),
        
        // Scene 14: Magic - Golden light
        SceneIllustration(
            sceneIndex: 14,
            gradientColors: ["#FFD700", "#FFA500", "#FF8C00"],
            iconName: "sun.max.fill",
            overlayText: "Goldenes Licht"
        ),
        
        // Scene 15: Stars - Star shines again
        SceneIllustration(
            sceneIndex: 15,
            gradientColors: ["#0f0c29", "#302b63", "#FFD700"],
            iconName: "star.fill",
            overlayText: "Der Stern leuchtet wieder"
        ),
        
        // Scene 16: Stars - Celebration
        SceneIllustration(
            sceneIndex: 16,
            gradientColors: ["#4facfe", "#00f2fe", "#FFD700"],
            iconName: "party.popper.fill",
            overlayText: "Freude und Dank"
        ),
        
        // Scene 17: Moon - Lost cloud
        SceneIllustration(
            sceneIndex: 17,
            gradientColors: ["#1a1a2e", "#4a4e69", "#9a8c98"],
            iconName: "cloud.rain.fill",
            overlayText: "Die verlorene Wolke"
        ),
        
        // Scene 18: Cloud - Cloud family lost
        SceneIllustration(
            sceneIndex: 18,
            gradientColors: ["#E0E7FF", "#C7D2FE", "#6366f1"],
            iconName: "wind",
            overlayText: "Von zu Hause weggeweht"
        ),
        
        // Scene 19: Stars - Klara's idea
        SceneIllustration(
            sceneIndex: 19,
            gradientColors: ["#667eea", "#764ba2", "#f093fb"],
            iconName: "brain.head.profile",
            overlayText: "Klaras Idee"
        ),
        
        // Scene 20: DreamSky - Star path
        SceneIllustration(
            sceneIndex: 20,
            gradientColors: ["#0f0c29", "#302b63", "#c77dff"],
            iconName: "arrow.forward",
            overlayText: "Der Sternenpfad"
        ),
        
        // Scene 21: Cloud - Reunion
        SceneIllustration(
            sceneIndex: 21,
            gradientColors: ["#E0E7FF", "#C7D2FE", "#FFD700"],
            iconName: "person.3.fill",
            overlayText: "Wiedervereinigung"
        ),
        
        // Scene 22: Cloud - Dream rain
        SceneIllustration(
            sceneIndex: 22,
            gradientColors: ["#4facfe", "#00f2fe", "#E0E7FF"],
            iconName: "cloud.heavyrain.fill",
            overlayText: "Regen aus Träumen"
        ),
        
        // Scene 23: DreamSky - Emma confident
        SceneIllustration(
            sceneIndex: 23,
            gradientColors: ["#667eea", "#764ba2", "#f093fb"],
            iconName: "crown.fill",
            overlayText: "Selbstbewusstsein"
        ),
        
        // Scene 24: Night - Darkness not scary
        SceneIllustration(
            sceneIndex: 24,
            gradientColors: ["#0f2027", "#203a43", "#2c5364"],
            iconName: "eye.fill",
            overlayText: "Keine Angst mehr"
        ),
        
        // Scene 25: Moon - Understanding
        SceneIllustration(
            sceneIndex: 25,
            gradientColors: ["#1a1a2e", "#4a4e69", "#c9b037"],
            iconName: "yin.yang",
            overlayText: "Licht und Dunkelheit"
        ),
        
        // Scene 26: Cozy - Goodbye
        SceneIllustration(
            sceneIndex: 26,
            gradientColors: ["#D4A574", "#FDF6E3", "#E67E22"],
            iconName: "hand.wave.fill",
            overlayText: "Abschied"
        ),
        
        // Scene 27: Bedroom - Returning
        SceneIllustration(
            sceneIndex: 27,
            gradientColors: ["#FFE4C4", "#DEB887", "#8B7355"],
            iconName: "arrow.down.circle.fill",
            overlayText: "Zurückkehren"
        ),
        
        // Scene 28: Bedroom - Window goodbye
        SceneIllustration(
            sceneIndex: 28,
            gradientColors: ["#2C3E50", "#4A6741", "#8B7355"],
            iconName: "rectangle.portrait.and.arrow.right",
            overlayText: "Bis morgen Nacht"
        ),
        
        // Scene 29: Moon - Klara disappears
        SceneIllustration(
            sceneIndex: 29,
            gradientColors: ["#1a1a2e", "#4a4e69", "#9a8c98"],
            iconName: "sparkles",
            overlayText: "In Mondstrahlen"
        ),
        
        // Scene 30: DreamSky - Happy end
        SceneIllustration(
            sceneIndex: 30,
            gradientColors: ["#667eea", "#764ba2", "#FFD700"],
            iconName: "moon.stars.fill",
            overlayText: "Die End"
        )
    ]
    
    // MARK: - Get Illustration for Scene
    static func illustration(for sceneIndex: Int) -> SceneIllustration {
        let index = sceneIndex - 1 // Convert to 0-based
        guard index >= 0 && index < sceneIllustrations.count else {
            return sceneIllustrations[0] // Default fallback
        }
        return sceneIllustrations[index]
    }
    
    // MARK: - Generate Gradient from Colors
    static func gradient(for sceneIndex: Int) -> LinearGradient {
        let illustration = illustration(for: sceneIndex)
        let colors = illustration.gradientColors.map { Color(hex: $0) }
        return LinearGradient(
            colors: colors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Scene Illustration Model
struct SceneIllustration {
    let sceneIndex: Int
    let gradientColors: [String]
    let iconName: String
    let overlayText: String
}

// MARK: - Sample Illustration View
struct SampleIllustrationView: View {
    let sceneIndex: Int
    
    var body: some View {
        let illustration = SampleIllustrations.illustration(for: sceneIndex)
        
        ZStack {
            // Gradient Background
            SampleIllustrations.gradient(for: sceneIndex)
            
            // Content
            VStack(spacing: 16) {
                Image(systemName: illustration.iconName)
                    .font(.system(size: 60, weight: .light))
                    .foregroundColor(.white.opacity(0.9))
                
                Text(illustration.overlayText)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.3))
                    )
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ScrollView {
        VStack(spacing: 20) {
            ForEach(1...6, id: \.self) { index in
                SampleIllustrationView(sceneIndex: index)
                    .frame(height: 200)
                    .cornerRadius(16)
                    .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }
}
