import Foundation

struct AIAPIStoryGeneratorService: StoryGeneratorService {
    let endpoint: URL
    let apiKey: String

    func generateStory(request: StoryRequest, children: [ChildProfileDTO]) async throws -> StoryDTO {
        var req = URLRequest(url: endpoint)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let payload = StoryGenerationPayload(request: request, children: children)
        req.httpBody = try JSONEncoder().encode(payload)

        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? "<no body>"
            throw NSError(domain: "AIAPIStoryGeneratorService", code: 1, userInfo: [NSLocalizedDescriptionKey: "API failed: \(body)"])
        }

        // Expect backend to return Story JSON matching app model.
        return try JSONDecoder().decode(StoryDTO.self, from: data)
    }
}

private struct StoryGenerationPayload: Codable {
    let request: StoryRequest
    let children: [ChildProfileDTO]
}
