import SwiftUI

// MARK: - Professional Theme for Children's Book Reader
// Warm, cozy color scheme inspired by classic children's book illustrations

enum ProfessionalTheme {
    
    // MARK: - Colors
    struct Colors {
        // Primary warm palette
        static let warmBrown = Color(hex: "#8B5A2B")
        static let cozyOrange = Color(hex: "#D4A574")
        static let softCream = Color(hex: "#FDF6E3")
        static let deepBrown = Color(hex: "#5D3A1A")
        static let goldenYellow = Color(hex: "#F4D03F")
        
        // Background gradients
        static let nightSkyStart = Color(hex: "#1a1a2e")
        static let nightSkyEnd = Color(hex: "#16213e")
        static let sunsetStart = Color(hex: "#FF6B6B")
        static let sunsetEnd = Color(hex: "#FFE66D")
        static let dreamStart = Color(hex: "#667eea")
        static let dreamEnd = Color(hex: "#764ba2")
        
        // UI Elements
        static let cardBackground = Color(hex: "#FFF8E7")
        static let textPrimary = Color(hex: "#3D2914")
        static let textSecondary = Color(hex: "#6B4423")
        static let accent = Color(hex: "#E67E22")
        
        // Navigation
        static let navButtonBackground = Color.white.opacity(0.9)
        static let navButtonForeground = Color(hex: "#5D3A1A")
    }
    
    // MARK: - Typography
    struct Typography {
        static let titleFont = Font.system(size: 28, weight: .bold, design: .rounded)
        static let storyTextFont = Font.system(size: 22, weight: .regular, design: .rounded)
        static let captionFont = Font.system(size: 14, weight: .medium, design: .rounded)
        static let buttonFont = Font.system(size: 16, weight: .semibold, design: .rounded)
        static let pageNumberFont = Font.system(size: 16, weight: .bold, design: .rounded)
    }
    
    // MARK: - Layout
    struct Layout {
        static let illustrationRatio: CGFloat = 0.70
        static let textCardRatio: CGFloat = 0.30
        static let cornerRadius: CGFloat = 24
        static let cardCornerRadius: CGFloat = 32
        static let navButtonSize: CGFloat = 56
        static let topBarHeight: CGFloat = 56
    }
    
    // MARK: - Shadows
    struct Shadows {
        static let cardShadow = ShadowStyle(
            color: Color.black.opacity(0.15),
            radius: 20,
            x: 0,
            y: -4
        )
        
        static let buttonShadow = ShadowStyle(
            color: Color.black.opacity(0.2),
            radius: 12,
            x: 0,
            y: 4
        )
        
        static let navButtonShadow = ShadowStyle(
            color: Color.black.opacity(0.3),
            radius: 8,
            x: 0,
            y: 2
        )
    }
    
    // MARK: - Gradients
    struct Gradients {
        static let warmBackground = LinearGradient(
            colors: [Colors.softCream, Colors.cozyOrange.opacity(0.3)],
            startPoint: .top,
            endPoint: .bottom
        )
        
        static let textCardGradient = LinearGradient(
            colors: [Colors.cardBackground, Colors.softCream],
            startPoint: .top,
            endPoint: .bottom
        )
        
        static let progressBar = LinearGradient(
            colors: [Colors.cozyOrange, Colors.goldenYellow],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

// MARK: - Shadow Style
struct ShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - View Modifiers
struct StoryCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(ProfessionalTheme.Gradients.textCardGradient)
            .cornerRadius(ProfessionalTheme.Layout.cardCornerRadius)
            .shadow(
                color: ProfessionalTheme.Shadows.cardShadow.color,
                radius: ProfessionalTheme.Shadows.cardShadow.radius,
                x: ProfessionalTheme.Shadows.cardShadow.x,
                y: ProfessionalTheme.Shadows.cardShadow.y
            )
    }
}

struct NavButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(width: ProfessionalTheme.Layout.navButtonSize, 
                   height: ProfessionalTheme.Layout.navButtonSize)
            .background(ProfessionalTheme.Colors.navButtonBackground)
            .foregroundColor(ProfessionalTheme.Colors.navButtonForeground)
            .clipShape(Circle())
            .shadow(
                color: ProfessionalTheme.Shadows.navButtonShadow.color,
                radius: ProfessionalTheme.Shadows.navButtonShadow.radius,
                x: ProfessionalTheme.Shadows.navButtonShadow.x,
                y: ProfessionalTheme.Shadows.navButtonShadow.y
            )
    }
}

extension View {
    func storyCardStyle() -> some View {
        modifier(StoryCardStyle())
    }
    
    func navButtonStyle() -> some View {
        modifier(NavButtonStyle())
    }
}

// MARK: - Illustration Placeholder Gradients
enum SceneIllustrationTheme: CaseIterable {
    case bedroom
    case dreamSky
    case moon
    case stars
    case cloud
    case magic
    case forest
    case cozy
    case night
    case sunrise
    
    var gradient: LinearGradient {
        switch self {
        case .bedroom:
            return LinearGradient(
                colors: [Color(hex: "#FFE4C4"), Color(hex: "#DEB887")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .dreamSky:
            return LinearGradient(
                colors: [Color(hex: "#667eea"), Color(hex: "#764ba2")],
                startPoint: .top,
                endPoint: .bottom
            )
        case .moon:
            return LinearGradient(
                colors: [Color(hex: "#1a1a2e"), Color(hex: "#4a4e69")],
                startPoint: .top,
                endPoint: .bottom
            )
        case .stars:
            return LinearGradient(
                colors: [Color(hex: "#0f0c29"), Color(hex: "#302b63")],
                startPoint: .top,
                endPoint: .bottom
            )
        case .cloud:
            return LinearGradient(
                colors: [Color(hex: "#E0E7FF"), Color(hex: "#C7D2FE")],
                startPoint: .top,
                endPoint: .bottom
            )
        case .magic:
            return LinearGradient(
                colors: [Color(hex: "#f093fb"), Color(hex: "#f5576c")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .forest:
            return LinearGradient(
                colors: [Color(hex: "#134E5E"), Color(hex: "#71B280")],
                startPoint: .top,
                endPoint: .bottom
            )
        case .cozy:
            return LinearGradient(
                colors: [Color(hex: "#D4A574"), Color(hex: "#8B5A2B")],
                startPoint: .top,
                endPoint: .bottom
            )
        case .night:
            return LinearGradient(
                colors: [Color(hex: "#0f2027"), Color(hex: "#203a43")],
                startPoint: .top,
                endPoint: .bottom
            )
        case .sunrise:
            return LinearGradient(
                colors: [Color(hex: "#FF6B6B"), Color(hex: "#FFE66D")],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
    
    var iconName: String {
        switch self {
        case .bedroom: return "bed.double.fill"
        case .dreamSky: return "cloud.moon.fill"
        case .moon: return "moon.stars.fill"
        case .stars: return "sparkles"
        case .cloud: return "cloud.fill"
        case .magic: return "wand.and.stars"
        case .forest: return "tree.fill"
        case .cozy: return "flame.fill"
        case .night: return "moon.fill"
        case .sunrise: return "sunrise.fill"
        }
    }
    
    static func forScene(_ index: Int) -> SceneIllustrationTheme {
        let allCases = Self.allCases
        return allCases[index % allCases.count]
    }
}
