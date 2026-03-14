import SwiftUI

// MARK: - Design System
// Einheitliches Design-System für die gesamte App

enum DesignTokens {
    
    // MARK: - Colors
    enum Colors {
        // Primary Brand Colors
        static let primary = Color(red: 0.45, green: 0.25, blue: 0.85)
        static let primaryLight = Color(red: 0.65, green: 0.45, blue: 0.95)
        static let primaryDark = Color(red: 0.30, green: 0.15, blue: 0.65)
        
        // Warm Cozy Colors (für Kinder-App)
        static let warmBackground = Color(red: 0.98, green: 0.96, blue: 0.94)
        static let warmCard = Color(red: 1.0, green: 0.99, blue: 0.97)
        static let warmAccent = Color(red: 0.95, green: 0.75, blue: 0.45)
        
        // Semantic Colors
        static let success = Color(red: 0.30, green: 0.70, blue: 0.45)
        static let warning = Color(red: 0.95, green: 0.60, blue: 0.20)
        static let error = Color(red: 0.90, green: 0.30, blue: 0.30)
        
        // Text Colors
        static let textPrimary = Color(red: 0.15, green: 0.15, blue: 0.20)
        static let textSecondary = Color(red: 0.45, green: 0.45, blue: 0.50)
        static let textTertiary = Color(red: 0.60, green: 0.60, blue: 0.65)
        
        // Gradients
        static var heroGradient: LinearGradient {
            LinearGradient(
                colors: [
                    Color(red: 0.50, green: 0.30, blue: 0.90),
                    Color(red: 0.70, green: 0.40, blue: 0.80),
                    Color(red: 0.90, green: 0.50, blue: 0.70)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        
        static var cardGradient: LinearGradient {
            LinearGradient(
                colors: [
                    Color.white.opacity(0.9),
                    Color.white.opacity(0.7)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
    
    // MARK: - Typography
    enum Typography {
        // Display Fonts (große Überschriften)
        static let displayLarge = Font.system(size: 34, weight: .bold, design: .rounded)
        static let displayMedium = Font.system(size: 28, weight: .bold, design: .rounded)
        static let displaySmall = Font.system(size: 24, weight: .semibold, design: .rounded)
        
        // Headline Fonts
        static let headlineLarge = Font.system(size: 22, weight: .bold, design: .rounded)
        static let headlineMedium = Font.system(size: 20, weight: .semibold, design: .rounded)
        static let headlineSmall = Font.system(size: 18, weight: .semibold, design: .rounded)
        
        // Body Fonts
        static let bodyLarge = Font.system(size: 17, weight: .regular, design: .rounded)
        static let bodyMedium = Font.system(size: 15, weight: .regular, design: .rounded)
        static let bodySmall = Font.system(size: 13, weight: .regular, design: .rounded)
        
        // Caption/Label Fonts
        static let caption = Font.system(size: 12, weight: .medium, design: .rounded)
        static let captionSmall = Font.system(size: 11, weight: .medium, design: .rounded)
        
        // Story Text
        static let storyText = Font.system(size: 19, weight: .regular, design: .serif)
        static let storyTitle = Font.system(size: 26, weight: .bold, design: .rounded)
    }
    
    // MARK: - Spacing
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
        
        // Section Spacing
        static let sectionSmall: CGFloat = 20
        static let sectionMedium: CGFloat = 32
        static let sectionLarge: CGFloat = 48
    }
    
    // MARK: - Corner Radius
    enum CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let xl: CGFloat = 32
        static let full: CGFloat = 9999
    }
    
    // MARK: - Shadows
    enum Shadows {
        static let small = ShadowStyle(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        static let medium = ShadowStyle(color: .black.opacity(0.12), radius: 16, x: 0, y: 8)
        static let large = ShadowStyle(color: .black.opacity(0.15), radius: 24, x: 0, y: 12)
        static let glow = ShadowStyle(color: Colors.primary.opacity(0.3), radius: 20, x: 0, y: 0)
    }
    
    struct ShadowStyle {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }
    
    // MARK: - Animation
    enum Animation {
        static let quick = SwiftUI.Animation.easeOut(duration: 0.2)
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let slow = SwiftUI.Animation.easeInOut(duration: 0.5)
        static let spring = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.8)
    }
    
    // MARK: - Layout
    enum Layout {
        static let maxContentWidth: CGFloat = 500
        static let cardWidth: CGFloat = 280
        static let cardHeight: CGFloat = 200
        static let iconSizeLarge: CGFloat = 80
        static let iconSizeMedium: CGFloat = 48
        static let iconSizeSmall: CGFloat = 24
    }
}

// MARK: - View Modifiers

struct GlassCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.large)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.large)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
            .shadow(
                color: DesignTokens.Shadows.medium.color,
                radius: DesignTokens.Shadows.medium.radius,
                x: DesignTokens.Shadows.medium.x,
                y: DesignTokens.Shadows.medium.y
            )
    }
}

struct PrimaryButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(DesignTokens.Typography.headlineSmall)
            .foregroundColor(.white)
            .padding(.horizontal, DesignTokens.Spacing.lg)
            .padding(.vertical, DesignTokens.Spacing.md)
            .background(
                Capsule()
                    .fill(DesignTokens.Colors.primary)
                    .shadow(
                        color: DesignTokens.Colors.primary.opacity(0.4),
                        radius: 12,
                        x: 0,
                        y: 6
                    )
            )
    }
}

struct FloatingCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(DesignTokens.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.large)
                    .fill(Color.white)
                    .shadow(
                        color: DesignTokens.Shadows.small.color,
                        radius: DesignTokens.Shadows.small.radius,
                        x: DesignTokens.Shadows.small.x,
                        y: DesignTokens.Shadows.small.y
                    )
            )
    }
}

// MARK: - View Extensions
extension View {
    func glassCard() -> some View {
        modifier(GlassCardModifier())
    }
    
    func primaryButton() -> some View {
        modifier(PrimaryButtonModifier())
    }
    
    func floatingCard() -> some View {
        modifier(FloatingCardModifier())
    }
}
