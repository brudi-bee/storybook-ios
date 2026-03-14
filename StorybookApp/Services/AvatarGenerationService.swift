import Foundation
import SwiftUI
import UIKit

// MARK: - Avatar Generation Error
enum AvatarGenerationError: Error, LocalizedError {
    case invalidConfiguration
    case networkError(Error)
    case apiError(String)
    case rateLimited
    case invalidResponse
    case imageDecodingFailed
    case apiKeyMissing
    case insufficientCredits
    case contentPolicyViolation
    
    var errorDescription: String? {
        switch self {
        case .invalidConfiguration:
            return "Ungültige Avatar-Konfiguration"
        case .networkError(let error):
            return "Netzwerkfehler: \(error.localizedDescription)"
        case .apiError(let message):
            return "API-Fehler: \(message)"
        case .rateLimited:
            return "Zu viele Anfragen. Bitte warte einen Moment."
        case .invalidResponse:
            return "Ungültige Antwort vom Server"
        case .imageDecodingFailed:
            return "Bild konnte nicht dekodiert werden"
        case .apiKeyMissing:
            return "API-Schlüssel fehlt. Bitte in den Einstellungen konfigurieren."
        case .insufficientCredits:
            return "Nicht genügend API-Guthaben"
        case .contentPolicyViolation:
            return "Inhalt verstößt gegen Richtlinien"
        }
    }
}

// MARK: - Avatar Generation Result
struct AvatarGenerationResult {
    let imageData: Data
    let prompt: String
    let revisedPrompt: String?
    let generationId: String
    let createdAt: Date
}

// MARK: - Character Sheet Result
struct CharacterSheetResult {
    let frontView: Data
    let sideView: Data?
    let backView: Data?
    let prompt: String
    let generationId: String
}

// MARK: - Scene Image Result
struct SceneImageResult {
    let imageData: Data
    let sceneIndex: Int
    let prompt: String
    let generationId: String
}

// MARK: - Avatar Generation Protocol
protocol AvatarGenerationService {
    func generateAvatar(for configuration: AvatarConfiguration, name: String, gender: GenderSelection) async throws -> AvatarGenerationResult
    func generateCharacterSheet(for configuration: AvatarConfiguration, name: String, gender: GenderSelection) async throws -> CharacterSheetResult
    func generateSceneImage(scene: StoryScene, characterReference: Data?, configuration: AvatarConfiguration) async throws -> SceneImageResult
    func isAvailable() -> Bool
    var serviceName: String { get }
}

// MARK: - Base Avatar Service
class BaseAvatarService {
    func buildAvatarPrompt(for configuration: AvatarConfiguration, name: String, gender: GenderSelection) -> String {
        let genderDesc = gender == .girl ? "female" : gender == .boy ? "male" : "gender-neutral"
        let styleDesc = buildStyleDescription(configuration.style)
        let features = [
            configuration.hairColor.promptDescription,
            configuration.skinTone.promptDescription,
            configuration.eyeColor.promptDescription
        ].joined(separator: ", ")
        
        let clothingDesc = buildClothingDescription(configuration.clothingColor.color)
        
        return """
        Create a children's storybook character portrait of \(name), a \(genderDesc) child \
        with \(features). \(styleDesc). \(clothingDesc). \
        The character should be friendly, age 4-8, with a warm smile. \
        Style: children's book illustration, soft colors, gentle lighting, \
        suitable for ages 3-8, wholesome and safe.
        """
    }
    
    func buildCharacterSheetPrompt(for configuration: AvatarConfiguration, name: String, gender: GenderSelection, view: String) -> String {
        let basePrompt = buildAvatarPrompt(for: configuration, name: name, gender: gender)
        return basePrompt + " View: \(view). Character reference sheet style, multiple angles, consistent character design."
    }
    
    func buildScenePrompt(scene: StoryScene, characterDescription: String) -> String {
        return """
        Children's book illustration scene: \(scene.text.prefix(100))... \
        Character: \(characterDescription). \
        Scene mood: \(scene.bgmMood). \
        Style: soft watercolor-like digital art, warm lighting, storybook aesthetic, \
        safe for children ages 3-8, no scary elements.
        """
    }
    
    private func buildStyleDescription(_ style: AvatarStyle) -> String {
        switch style {
        case .animalRabbit:
            return "Cute anthropomorphic rabbit character with soft fur and long ears"
        case .animalBear:
            return "Cute anthropomorphic bear character with fluffy fur and round ears"
        case .animalFox:
            return "Cute anthropomorphic fox character with bushy tail and pointy ears"
        case .cartoon:
            return "Cartoon style with big expressive eyes and rounded features"
        case .realistic:
            return "Semi-realistic illustration style with detailed features"
        }
    }
    
    private func buildClothingDescription(_ color: Color) -> String {
        let uiColor = UIColor(color)
        var hue: CGFloat = 0
        uiColor.getHue(&hue, saturation: nil, brightness: nil, alpha: nil)
        
        let colorName: String
        switch hue {
        case 0..<0.08: colorName = "red"
        case 0.08..<0.17: colorName = "orange"
        case 0.17..<0.33: colorName = "yellow"
        case 0.33..<0.45: colorName = "green"
        case 0.45..<0.65: colorName = "blue"
        case 0.65..<0.85: colorName = "purple"
        default: colorName = "colorful"
        }
        
        return "Wearing comfortable \(colorName) children's clothing"
    }
}

// MARK: - Mock Avatar Service
class MockAvatarService: BaseAvatarService, AvatarGenerationService {
    var serviceName: String { "Mock Avatar Generator" }
    
    func isAvailable() -> Bool {
        return true
    }
    
    func generateAvatar(for configuration: AvatarConfiguration, name: String, gender: GenderSelection) async throws -> AvatarGenerationResult {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_500_000_000)
        
        // Generate a placeholder gradient image
        let imageData = createPlaceholderAvatarImage(configuration: configuration, name: name)
        
        return AvatarGenerationResult(
            imageData: imageData,
            prompt: buildAvatarPrompt(for: configuration, name: name, gender: gender),
            revisedPrompt: nil,
            generationId: "mock_\(UUID().uuidString)",
            createdAt: Date()
        )
    }
    
    func generateCharacterSheet(for configuration: AvatarConfiguration, name: String, gender: GenderSelection) async throws -> CharacterSheetResult {
        try await Task.sleep(nanoseconds: 2_000_000_000)
        
        let frontImage = createPlaceholderAvatarImage(configuration: configuration, name: name)
        let sideImage = createPlaceholderAvatarImage(configuration: configuration, name: name, isSideView: true)
        
        return CharacterSheetResult(
            frontView: frontImage,
            sideView: sideImage,
            backView: nil,
            prompt: buildCharacterSheetPrompt(for: configuration, name: name, gender: gender, view: "front and side"),
            generationId: "mock_sheet_\(UUID().uuidString)"
        )
    }
    
    func generateSceneImage(scene: StoryScene, characterReference: Data?, configuration: AvatarConfiguration) async throws -> SceneImageResult {
        try await Task.sleep(nanoseconds: 2_500_000_000)
        
        let characterDesc = "Child character with \(configuration.hairColor.promptDescription)"
        let imageData = createPlaceholderSceneImage(scene: scene)
        
        return SceneImageResult(
            imageData: imageData,
            sceneIndex: scene.index,
            prompt: buildScenePrompt(scene: scene, characterDescription: characterDesc),
            generationId: "mock_scene_\(UUID().uuidString)"
        )
    }
    
    // MARK: - Placeholder Image Generation
    private func createPlaceholderAvatarImage(configuration: AvatarConfiguration, name: String, isSideView: Bool = false) -> Data {
        let size = CGSize(width: 512, height: 512)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            let ctx = context.cgContext
            
            // Background gradient
            let colors = [
                configuration.clothingColor.color.cgColor!,
                configuration.skinTone.color.cgColor!
            ]
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                     colors: colors as CFArray,
                                     locations: [0, 1])!
            ctx.drawLinearGradient(gradient,
                                  start: CGPoint(x: 0, y: 0),
                                  end: CGPoint(x: size.width, y: size.height),
                                  options: [])
            
            // Draw avatar representation
            let centerX = size.width / 2
            let centerY = size.height / 2
            
            // Head circle
            let headRadius: CGFloat = 100
            ctx.setFillColor(configuration.skinTone.color.cgColor!)
            ctx.fillEllipse(in: CGRect(x: centerX - headRadius,
                                      y: centerY - headRadius - 20,
                                      width: headRadius * 2,
                                      height: headRadius * 2))
            
            // Hair
            ctx.setFillColor(configuration.hairColor.color.cgColor!)
            ctx.fillEllipse(in: CGRect(x: centerX - headRadius - 10,
                                      y: centerY - headRadius - 40,
                                      width: headRadius * 2 + 20,
                                      height: headRadius))
            
            // Eyes
            let eyeOffset: CGFloat = isSideView ? 20 : 30
            ctx.setFillColor(configuration.eyeColor.color.cgColor!)
            ctx.fillEllipse(in: CGRect(x: centerX - eyeOffset - 15,
                                      y: centerY - 35,
                                      width: 30,
                                      height: 30))
            if !isSideView {
                ctx.fillEllipse(in: CGRect(x: centerX + eyeOffset - 15,
                                          y: centerY - 35,
                                          width: 30,
                                          height: 30))
            }
            
            // Smile
            ctx.setStrokeColor(UIColor.black.cgColor)
            ctx.setLineWidth(3)
            ctx.addArc(center: CGPoint(x: centerX, y: centerY + 10),
                      radius: 30,
                      startAngle: 0.2 * .pi,
                      endAngle: 0.8 * .pi,
                      clockwise: false)
            ctx.strokePath()
            
            // Style indicator
            let styleText = configuration.style.displayName
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24, weight: .bold),
                .foregroundColor: UIColor.white
            ]
            let textSize = styleText.size(withAttributes: attributes)
            styleText.draw(at: CGPoint(x: centerX - textSize.width / 2, y: size.height - 60),
                          withAttributes: attributes)
            
            // Name
            let nameAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 32, weight: .bold),
                .foregroundColor: UIColor.white
            ]
            let nameSize = name.size(withAttributes: nameAttributes)
            name.draw(at: CGPoint(x: centerX - nameSize.width / 2, y: 40),
                     withAttributes: nameAttributes)
        }
        
        return image.pngData()!
    }
    
    private func createPlaceholderSceneImage(scene: StoryScene) -> Data {
        let size = CGSize(width: 1024, height: 1024)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            let ctx = context.cgContext
            
            // Background based on mood
            let colors: [CGColor]
            switch scene.bgmMood {
            case "calm":
                colors = [UIColor.blue.cgColor, UIColor.cyan.cgColor]
            case "happy":
                colors = [UIColor.yellow.cgColor, UIColor.orange.cgColor]
            case "adventure":
                colors = [UIColor.green.cgColor, UIColor.brown.cgColor]
            default:
                colors = [UIColor.purple.cgColor, UIColor.pink.cgColor]
            }
            
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                     colors: colors as CFArray,
                                     locations: [0, 1])!
            ctx.drawLinearGradient(gradient,
                                  start: CGPoint(x: 0, y: 0),
                                  end: CGPoint(x: size.width, y: size.height),
                                  options: [])
            
            // Scene text
            let text = "Scene \(scene.index)"
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 48, weight: .bold),
                .foregroundColor: UIColor.white
            ]
            let textSize = text.size(withAttributes: attributes)
            text.draw(at: CGPoint(x: size.width / 2 - textSize.width / 2,
                                 y: size.height / 2 - textSize.height / 2),
                     withAttributes: attributes)
            
            // Mood indicator
            let moodAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24),
                .foregroundColor: UIColor.white.withAlphaComponent(0.8)
            ]
            let moodText = "Mood: \(scene.bgmMood)"
            moodText.draw(at: CGPoint(x: 40, y: size.height - 60),
                         withAttributes: moodAttributes)
        }
        
        return image.pngData()!
    }
}

// MARK: - DALL-E Avatar Service
class DALLEAvatarService: BaseAvatarService, AvatarGenerationService {
    var serviceName: String { "DALL-E 3" }
    
    private let apiKey: String
    private let endpoint: URL
    private let urlSession: URLSession
    
    init(apiKey: String, endpoint: URL? = nil, urlSession: URLSession = .shared) {
        self.apiKey = apiKey
        self.endpoint = endpoint ?? URL(string: "https://api.openai.com/v1/images/generations")!
        self.urlSession = urlSession
    }
    
    convenience init?() {
        guard let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] else {
            return nil
        }
        self.init(apiKey: apiKey)
    }
    
    func isAvailable() -> Bool {
        return !apiKey.isEmpty
    }
    
    func generateAvatar(for configuration: AvatarConfiguration, name: String, gender: GenderSelection) async throws -> AvatarGenerationResult {
        let prompt = buildAvatarPrompt(for: configuration, name: name, gender: gender)
        return try await generateImage(prompt: prompt, size: "1024x1024", quality: "standard")
    }
    
    func generateCharacterSheet(for configuration: AvatarConfiguration, name: String, gender: GenderSelection) async throws -> CharacterSheetResult {
        // Generate front view
        let frontPrompt = buildCharacterSheetPrompt(for: configuration, name: name, gender: gender, view: "front view, full body")
        let frontResult = try await generateImage(prompt: frontPrompt, size: "1024x1024", quality: "standard")
        
        // Generate side view
        let sidePrompt = buildCharacterSheetPrompt(for: configuration, name: name, gender: gender, view: "side profile view, full body")
        let sideResult = try await generateImage(prompt: sidePrompt, size: "1024x1024", quality: "standard")
        
        return CharacterSheetResult(
            frontView: frontResult.imageData,
            sideView: sideResult.imageData,
            backView: nil,
            prompt: frontPrompt,
            generationId: frontResult.generationId
        )
    }
    
    func generateSceneImage(scene: StoryScene, characterReference: Data?, configuration: AvatarConfiguration) async throws -> SceneImageResult {
        let characterDesc = buildAvatarPrompt(for: configuration, name: "the character", gender: .neutral)
        let prompt = buildScenePrompt(scene: scene, characterDescription: characterDesc)
        
        let result = try await generateImage(prompt: prompt, size: "1024x1024", quality: "standard")
        
        return SceneImageResult(
            imageData: result.imageData,
            sceneIndex: scene.index,
            prompt: prompt,
            generationId: result.generationId
        )
    }
    
    // MARK: - DALL-E API Call
    private func generateImage(prompt: String, size: String, quality: String) async throws -> AvatarGenerationResult {
        let requestBody: [String: Any] = [
            "model": "dall-e-3",
            "prompt": prompt,
            "n": 1,
            "size": size,
            "quality": quality,
            "response_format": "b64_json"
        ]
        
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 120 // 2 minutes for image generation
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            throw AvatarGenerationError.apiError("Failed to encode request")
        }
        
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await urlSession.data(for: request)
        } catch {
            throw AvatarGenerationError.networkError(error)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AvatarGenerationError.invalidResponse
        }
        
        // Handle HTTP errors
        if httpResponse.statusCode == 429 {
            throw AvatarGenerationError.rateLimited
        }
        
        if httpResponse.statusCode == 400 {
            if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = errorJson["error"] as? [String: Any],
               let message = error["message"] as? String {
                if message.contains("safety") || message.contains("content policy") {
                    throw AvatarGenerationError.contentPolicyViolation
                }
            }
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let message = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw AvatarGenerationError.apiError("HTTP \(httpResponse.statusCode): \(message)")
        }
        
        // Parse response
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let dataArray = json["data"] as? [[String: Any]],
              let firstImage = dataArray.first,
              let b64String = firstImage["b64_json"] as? String,
              let imageData = Data(base64Encoded: b64String) else {
            throw AvatarGenerationError.imageDecodingFailed
        }
        
        let revisedPrompt = firstImage["revised_prompt"] as? String
        let generationId = json["id"] as? String ?? UUID().uuidString
        
        return AvatarGenerationResult(
            imageData: imageData,
            prompt: prompt,
            revisedPrompt: revisedPrompt,
            generationId: generationId,
            createdAt: Date()
        )
    }
}

// MARK: - Avatar Service Factory
enum AvatarServiceFactory {
    static func createService(useRealGeneration: Bool) -> AvatarGenerationService {
        if useRealGeneration {
            if let dalleService = DALLEAvatarService() {
                return dalleService
            }
            print("Warning: DALL-E service not available, falling back to mock")
        }
        return MockAvatarService()
    }
    
    static func createMockService() -> AvatarGenerationService {
        return MockAvatarService()
    }
    
    static func createDALLEService(apiKey: String) -> AvatarGenerationService {
        return DALLEAvatarService(apiKey: apiKey)
    }
}