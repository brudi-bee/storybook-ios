import Foundation

// MARK: - API Error Enum
enum APIError: Error, LocalizedError {
    case network(Error)
    case decoding(Error)
    case server(Int, String)
    case invalidURL
    case invalidResponse
    case fileNotFound
    case maxRetriesExceeded
    
    var errorDescription: String? {
        switch self {
        case .network(let error):
            return "Netzwerkfehler: \(error.localizedDescription)"
        case .decoding(let error):
            return "Fehler beim Dekodieren: \(error.localizedDescription)"
        case .server(let code, let message):
            return "Server-Fehler (\(code)): \(message)"
        case .invalidURL:
            return "Ungültige URL"
        case .invalidResponse:
            return "Ungültige Antwort vom Server"
        case .fileNotFound:
            return "Datei nicht gefunden"
        case .maxRetriesExceeded:
            return "Maximale Anzahl von Wiederholungsversuchen überschritten"
        }
    }
}

// MARK: - Generated Story (Response Model)
struct GeneratedStory: Codable {
    let title: String
    let language: String
    let genre: String
    let setting: String
    let moral: String
    let scenes: [GeneratedScene]
    let createdAt: Date?
    
    struct GeneratedScene: Codable {
        let index: Int
        let text: String
        let imagePrompt: String
        let bgmMood: String
    }
}

// MARK: - Retry Configuration
struct RetryConfig {
    let maxRetries: Int
    let baseDelay: TimeInterval
    let maxDelay: TimeInterval
    let backoffMultiplier: Double

    init(
        maxRetries: Int = 3,
        baseDelay: TimeInterval = 1.0,
        maxDelay: TimeInterval = 30.0,
        backoffMultiplier: Double = 2.0
    ) {
        self.maxRetries = maxRetries
        self.baseDelay = baseDelay
        self.maxDelay = maxDelay
        self.backoffMultiplier = backoffMultiplier
    }
    
    /// Berechnet den Delay für einen Retry-Versuch mit Exponential Backoff + Jitter
    func delay(forAttempt attempt: Int) -> TimeInterval {
        guard attempt > 0 else { return 0 }
        let exponentialDelay = baseDelay * pow(backoffMultiplier, Double(attempt - 1))
        let jitter = Double.random(in: 0...0.1) * exponentialDelay
        return min(exponentialDelay + jitter, maxDelay)
    }
}

// MARK: - API Service
class APIService {
    private let urlSession: URLSession
    private let retryConfig: RetryConfig
    private let decoder: JSONDecoder
    
    init(
        urlSession: URLSession = .shared,
        retryConfig: RetryConfig = RetryConfig()
    ) {
        self.urlSession = urlSession
        self.retryConfig = retryConfig
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }
    
    // MARK: - Public Methods
    
    /// Lädt eine Geschichte von einer URL (HTTP oder lokale Datei)
    /// - Parameter url: Die URL zur JSON-Datei (http://, https://, oder file://)
    /// - Returns: Ein GeneratedStory Objekt
    /// - Throws: APIError bei Fehlern
    func fetchStory(from url: URL) async throws -> GeneratedStory {
        // Unterscheide zwischen lokaler Datei und HTTP-Request
        if url.isFileURL {
            return try await fetchLocalStory(from: url)
        } else {
            return try await fetchRemoteStory(from: url)
        }
    }
    
    // MARK: - Private Methods
    
    /// Lädt eine Geschichte von einer lokalen JSON-Datei
    private func fetchLocalStory(from url: URL) async throws -> GeneratedStory {
        do {
            let data = try Data(contentsOf: url)
            return try decodeStory(from: data)
        } catch let error as APIError {
            throw error
        } catch {
            if (error as NSError).code == NSFileReadNoSuchFileError {
                throw APIError.fileNotFound
            }
            throw APIError.network(error)
        }
    }
    
    /// Lädt eine Geschichte von einem HTTP/HTTPS-Endpunkt mit Retry-Logik
    private func fetchRemoteStory(from url: URL) async throws -> GeneratedStory {
        var lastError: Error?
        
        for attempt in 1...retryConfig.maxRetries {
            do {
                let story = try await performRequest(url: url)
                return story
            } catch let error as APIError {
                lastError = error
                
                // Nicht-wiederholbare Fehler sofort werfen
                switch error {
                case .decoding, .invalidURL, .fileNotFound:
                    throw error
                case .server(let code, _):
                    // Nur bestimmte Status-Codes wiederholen
                    let retryableCodes = [408, 429, 500, 502, 503, 504]
                    if !retryableCodes.contains(code) {
                        throw error
                    }
                default:
                    break
                }
                
                // Letzter Versuch erreicht
                if attempt >= retryConfig.maxRetries {
                    break
                }
                
                // Warte vor dem nächsten Versuch
                let delay = retryConfig.delay(forAttempt: attempt)
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                
            } catch {
                lastError = error
                if attempt >= retryConfig.maxRetries {
                    break
                }
                let delay = retryConfig.delay(forAttempt: attempt)
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }
        }
        
        // Alle Versuche aufgebraucht
        if let apiError = lastError as? APIError {
            throw apiError
        } else {
            throw APIError.maxRetriesExceeded
        }
    }
    
    /// Führt einen einzelnen HTTP-Request aus
    private func performRequest(url: URL) async throws -> GeneratedStory {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 30
        
        do {
            let (data, response) = try await urlSession.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            // Prüfe auf HTTP-Fehler
            guard (200...299).contains(httpResponse.statusCode) else {
                let message = String(data: data, encoding: .utf8) ?? "Unbekannter Fehler"
                throw APIError.server(httpResponse.statusCode, message)
            }
            
            return try decodeStory(from: data)
            
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.network(error)
        }
    }
    
    /// Dekodiert JSON-Daten in ein GeneratedStory Objekt
    private func decodeStory(from data: Data) throws -> GeneratedStory {
        do {
            return try decoder.decode(GeneratedStory.self, from: data)
        } catch {
            throw APIError.decoding(error)
        }
    }
}

// MARK: - Convenience Extensions
extension APIService {
    /// Lädt eine Geschichte von einem String (URL oder Dateipfad)
    func fetchStory(from urlString: String) async throws -> GeneratedStory {
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        return try await fetchStory(from: url)
    }
    
    /// Lädt eine Geschichte aus einer Bundle-Ressource
    func fetchStoryFromBundle(named name: String, withExtension ext: String = "json") async throws -> GeneratedStory {
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
            throw APIError.fileNotFound
        }
        return try await fetchStory(from: url)
    }
    
    /// Führt einen Health Check für einen Endpunkt durch
    func healthCheck(url: URL) async -> Bool {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
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
