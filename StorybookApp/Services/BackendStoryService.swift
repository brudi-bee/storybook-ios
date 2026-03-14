import Foundation

// MARK: - API Errors
enum StoryAPIError: Error, LocalizedError {
    case invalidURL
    case encodingFailed
    case networkError(Error)
    case invalidResponse
    case httpError(Int, String)
    case decodingFailed(Error)
    case rateLimited(retryAfter: Int?)
    case serverError
    case validationFailed([String: String])
    case apiKeyMissing
    case maxRetriesExceeded
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Ungültige API-URL"
        case .encodingFailed:
            return "Fehler beim Kodieren der Anfrage"
        case .networkError(let error):
            return "Netzwerkfehler: \(error.localizedDescription)"
        case .invalidResponse:
            return "Ungültige Server-Antwort"
        case .httpError(let code, let message):
            return "Server-Fehler (\(code)): \(message)"
        case .decodingFailed(let error):
            return "Fehler beim Verarbeiten der Antwort: \(error.localizedDescription)"
        case .rateLimited:
            return "Zu viele Anfragen. Bitte warte einen Moment."
        case .serverError:
            return "Server-Fehler. Bitte später erneut versuchen."
        case .validationFailed(let errors):
            let messages = errors.map { "\($0.key): \($0.value)" }.joined(separator: ", ")
            return "Validierungsfehler: \(messages)"
        case .apiKeyMissing:
            return "API-Schlüssel fehlt"
        case .maxRetriesExceeded:
            return "Maximale Anzahl von Versuchen überschritten"
        }
    }
}

// MARK: - API Response Models
struct StoryAPIResponse: Codable {
    let id: String
    let title: String
    let language: String
    let genre: String
    let setting: String
    let moral: String
    let createdAt: String
    let scenes: [StoryAPIScene]
    let contentSafety: ContentSafety?
}

struct StoryAPIScene: Codable {
    let index: Int
    let text: String
    let imagePrompt: String
    let bgmMood: String
}

struct ContentSafety: Codable {
    let rating: String
    let flags: [String]?
}

struct APIErrorResponse: Codable {
    let error: String
    let code: String?
    let details: [String: String]?
}

// MARK: - Retry Configuration
struct RetryConfiguration {
    var maxRetries: Int = 3
    var baseDelay: TimeInterval = 1.0
    var maxDelay: TimeInterval = 30.0
    var backoffMultiplier: Double = 2.0
    var retryableStatusCodes: Set<Int> = [408, 429, 500, 502, 503, 504]
    
    func delay(forAttempt attempt: Int) -> TimeInterval {
        let exponentialDelay = baseDelay * pow(backoffMultiplier, Double(attempt - 1))
        let jitter = Double.random(in: 0...0.1) * exponentialDelay
        return min(exponentialDelay + jitter, maxDelay)
    }
}

// MARK: - Backend Story Service
@MainActor
final class BackendStoryService: ObservableObject, StoryGeneratorService {
    @Published var lastError: StoryAPIError?
    @Published var isRetrying = false
    @Published var retryAttempt = 0
    
    private let endpoint: URL
    private let apiKey: String
    private let retryConfig: RetryConfiguration
    private let urlSession: URLSession
    
    init(
        endpoint: URL? = nil,
        apiKey: String? = nil,
        retryConfig: RetryConfiguration = RetryConfiguration(),
        urlSession: URLSession = .shared
    ) throws {
        // Versuche zuerst Umgebungsvariablen, dann Parameter
        let envEndpoint = ProcessInfo.processInfo.environment["STORYBOOK_API_URL"]
        let envKey = ProcessInfo.processInfo.environment["STORYBOOK_API_KEY"]
        
        guard let finalEndpoint = endpoint ?? (envEndpoint.flatMap { URL(string: $0) }) else {
            throw StoryAPIError.invalidURL
        }
        
        guard let finalKey = apiKey ?? envKey else {
            throw StoryAPIError.apiKeyMissing
        }
        
        self.endpoint = finalEndpoint
        self.apiKey = finalKey
        self.retryConfig = retryConfig
        self.urlSession = urlSession
    }
    
    convenience init() throws {
        // Standard: Produktions-Endpunkt (kann via Info.plist oder Umgebungsvariable überschrieben werden)
        let defaultURL = URL(string: "https://api.storybook-ai.de/v1/stories/generate")
        try self.init(endpoint: defaultURL, apiKey: nil)
    }
    
    convenience init(apiService: APIService) throws {
        // Convenience init that takes an APIService (for compatibility)
        let defaultURL = URL(string: "https://api.storybook-ai.de/v1/stories/generate")
        try self.init(endpoint: defaultURL, apiKey: nil)
    }
    
    // MARK: - Story Generation
    func generateStory(request: StoryRequest, children: [ChildProfileDTO]) async throws -> StoryDTO {
        lastError = nil
        isRetrying = false
        retryAttempt = 0
        
        let payload = StoryGenerationPayload(
            language: request.language.rawValue,
            genre: request.genre.rawValue,
            setting: request.setting,
            moral: request.moral,
            sceneCount: request.sceneCount,
            ageRange: request.ageRange,
            children: children.map { ChildPayload(name: $0.name, gender: $0.gender.rawValue, order: 0) }
        )
        
        return try await executeWithRetry(payload: payload)
    }
    
    // MARK: - Retry Logic
    private func executeWithRetry(payload: StoryGenerationPayload) async throws -> StoryDTO {
        var lastError: Error?
        
        for attempt in 1...retryConfig.maxRetries {
            self.retryAttempt = attempt
            
            do {
                let story = try await performRequest(payload: payload)
                self.isRetrying = false
                return story
            } catch let error as StoryAPIError {
                lastError = error
                
                // Nicht wiederholbare Fehler sofort werfen
                switch error {
                case .invalidURL, .encodingFailed, .decodingFailed, .validationFailed, .apiKeyMissing:
                    throw error
                case .httpError(let code, _):
                    if !retryConfig.retryableStatusCodes.contains(code) {
                        throw error
                    }
                default:
                    break
                }
                
                // Rate Limit hat spezielle Behandlung
                if case .rateLimited(let retryAfter) = error {
                    let delay = retryAfter.map { TimeInterval($0) } ?? retryConfig.delay(forAttempt: attempt)
                    await wait(seconds: delay)
                    continue
                }
                
                // Retry mit Backoff
                if attempt < retryConfig.maxRetries {
                    isRetrying = true
                    let delay = retryConfig.delay(forAttempt: attempt)
                    await wait(seconds: delay)
                }
            } catch {
                lastError = error
                if attempt < retryConfig.maxRetries {
                    isRetrying = true
                    let delay = retryConfig.delay(forAttempt: attempt)
                    await wait(seconds: delay)
                }
            }
        }
        
        self.isRetrying = false
        
        // Alle Versuche aufgebraucht
        if let storyError = lastError as? StoryAPIError {
            throw storyError
        } else {
            throw StoryAPIError.maxRetriesExceeded
        }
    }
    
    private func wait(seconds: TimeInterval) async {
        try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
    }
    
    // MARK: - API Request
    private func performRequest(payload: StoryGenerationPayload) async throws -> StoryDTO {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 60 // 60 Sekunden Timeout für Story-Generation
        
        // Encoding
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        
        do {
            request.httpBody = try encoder.encode(payload)
        } catch {
            throw StoryAPIError.encodingFailed
        }
        
        // Network Request
        let data: Data
        let response: URLResponse
        
        do {
            (data, response) = try await urlSession.data(for: request)
        } catch {
            throw StoryAPIError.networkError(error)
        }
        
        // Response Handling
        guard let httpResponse = response as? HTTPURLResponse else {
            throw StoryAPIError.invalidResponse
        }
        
        // Error Response Handling
        if !(200...299).contains(httpResponse.statusCode) {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unbekannter Fehler"
            
            // Versuche strukturierte Fehlerantwort zu parsen
            if let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                if httpResponse.statusCode == 429 {
                    let retryAfter = httpResponse.value(forHTTPHeaderField: "Retry-After").flatMap { Int($0) }
                    throw StoryAPIError.rateLimited(retryAfter: retryAfter)
                }
                throw StoryAPIError.httpError(httpResponse.statusCode, apiError.error)
            }
            
            if httpResponse.statusCode == 429 {
                throw StoryAPIError.rateLimited(retryAfter: nil)
            }
            
            throw StoryAPIError.httpError(httpResponse.statusCode, errorMessage)
        }
        
        // Success Response Decoding
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            let apiResponse = try decoder.decode(StoryAPIResponse.self, from: data)
            return mapAPIResponseToStory(apiResponse, children: payload.children.map { 
                ChildProfileDTO(name: $0.name, gender: ChildGender(rawValue: $0.gender) ?? .neutral)
            })
        } catch {
            throw StoryAPIError.decodingFailed(error)
        }
    }
    
    // MARK: - Mapping
    private func mapAPIResponseToStory(_ response: StoryAPIResponse, children: [ChildProfileDTO]) -> StoryDTO {
        let scenes = response.scenes.map { apiScene in
            StoryScene(
                index: apiScene.index,
                text: apiScene.text,
                imagePrompt: apiScene.imagePrompt,
                bgmMood: apiScene.bgmMood
            )
        }
        
        return StoryDTO(
            title: response.title,
            language: StoryLanguage(rawValue: response.language) ?? .de,
            genre: StoryGenre(rawValue: response.genre) ?? .bedtime,
            setting: response.setting,
            moral: response.moral,
            children: children,
            scenes: scenes
        )
    }
    
    // MARK: - Health Check
    func checkAPIHealth() async -> Bool {
        var request = URLRequest(url: endpoint.deletingLastPathComponent().appendingPathComponent("health"))
        request.httpMethod = "GET"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 10
        
        do {
            let (_, response) = try await urlSession.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else { return false }
            return (200...299).contains(httpResponse.statusCode)
        } catch {
            return false
        }
    }
}

// MARK: - Request Payload
private struct StoryGenerationPayload: Codable {
    let language: String
    let genre: String
    let setting: String
    let moral: String
    let sceneCount: Int
    let ageRange: String
    let children: [ChildPayload]
}

private struct ChildPayload: Codable {
    let name: String
    let gender: String
    let order: Int
}

// MARK: - Fallback Service
/// Kombiniert Backend + Mock als Fallback
@MainActor
final class HybridStoryService: ObservableObject, StoryGeneratorService {
    @Published var usingFallback = false
    @Published var lastError: StoryAPIError?
    
    private let backendService: BackendStoryService?
    private let mockService = MockStoryGeneratorService()
    
    init(useBackend: Bool = true) {
        if useBackend {
            do {
                self.backendService = try BackendStoryService()
            } catch {
                self.backendService = nil
                self.usingFallback = true
            }
        } else {
            self.backendService = nil
            self.usingFallback = true
        }
    }
    
    func generateStory(request: StoryRequest, children: [ChildProfileDTO]) async throws -> StoryDTO {
        if let backend = backendService, !usingFallback {
            do {
                let story = try await backend.generateStory(request: request, children: children)
                usingFallback = false
                return story
            } catch {
                lastError = error as? StoryAPIError
                usingFallback = true
                // Fallback zur Mock-Implementierung
                return try await mockService.generateStory(request: request, children: children)
            }
        } else {
            return try await mockService.generateStory(request: request, children: children)
        }
    }
    
    func resetFallback() {
        usingFallback = false
        lastError = nil
    }
}
