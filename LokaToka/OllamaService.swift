import Foundation

class OllamaService {
    static let shared = OllamaService()
    private init() {}

    func fetchModels(serverURL: String) async throws -> [OllamaModel] {
        guard let url = URL(string: "\(serverURL)/api/tags") else {
            throw OllamaError.invalidURL
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw OllamaError.serverError
        }
        let tagsResponse = try JSONDecoder().decode(OllamaTagsResponse.self, from: data)
        return tagsResponse.models
    }

    func chat(serverURL: String, model: String, messages: [ChatMessage]) async throws -> String {
        guard let url = URL(string: "\(serverURL)/api/chat") else {
            throw OllamaError.invalidURL
        }
        let ollamaMessages = messages.map { OllamaChatMessage(role: $0.role, content: $0.content) }
        let body = OllamaChatRequest(model: model, messages: ollamaMessages, stream: false)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        request.timeoutInterval = 120

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw OllamaError.serverError
        }
        let chatResponse = try JSONDecoder().decode(OllamaChatResponse.self, from: data)
        return chatResponse.message.content
    }
}

enum OllamaError: LocalizedError {
    case invalidURL
    case serverError

    var errorDescription: String? {
        switch self {
        case .invalidURL:   return "Ungültige Server-URL"
        case .serverError:  return "Server nicht erreichbar oder Fehler bei der Anfrage"
        }
    }
}
