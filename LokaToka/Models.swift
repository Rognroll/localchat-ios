import Foundation

struct ChatMessage: Identifiable, Codable, Equatable {
    let id: UUID
    let role: String
    let content: String
    let timestamp: Date

    init(id: UUID = UUID(), role: String, content: String, timestamp: Date = Date()) {
        self.id = id
        self.role = role
        self.content = content
        self.timestamp = timestamp
    }
}

struct OllamaModel: Identifiable, Codable, Hashable {
    let name: String
    var id: String { name }
}

struct OllamaTagsResponse: Codable {
    let models: [OllamaModel]
}

struct OllamaChatRequest: Codable {
    let model: String
    let messages: [OllamaChatMessage]
    let stream: Bool
}

struct OllamaChatMessage: Codable {
    let role: String
    let content: String
}

struct OllamaChatResponse: Codable {
    let message: OllamaChatMessage
}
