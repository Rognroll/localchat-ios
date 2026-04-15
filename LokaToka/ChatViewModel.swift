import Foundation

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isProcessing = false
    @Published var errorMessage: String?
    @Published var inputText = ""

    let speechManager = SpeechManager()
    let ttsManager = TTSManager()

    private var serverURL: String {
        UserDefaults.standard.string(forKey: "ollamaServerURL") ?? "http://192.168.1.123:11434"
    }

    private var selectedModel: String {
        let m = UserDefaults.standard.string(forKey: "ollamaModel") ?? ""
        return m.isEmpty ? "llama3" : m
    }

    private var ttsEnabled: Bool {
        UserDefaults.standard.object(forKey: "ttsEnabled") == nil
            ? true
            : UserDefaults.standard.bool(forKey: "ttsEnabled")
    }

    private var ttsLanguage: String {
        UserDefaults.standard.string(forKey: "ttsLanguage") ?? "de-DE"
    }

    private var ttsRate: Float {
        let r = UserDefaults.standard.float(forKey: "ttsRate")
        return r == 0 ? 0.5 : r
    }

    func sendMessage(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isProcessing else { return }

        messages.append(ChatMessage(role: "user", content: trimmed))
        inputText = ""
        errorMessage = nil
        isProcessing = true

        Task {
            do {
                let reply = try await OllamaService.shared.chat(
                    serverURL: serverURL,
                    model: selectedModel,
                    messages: messages
                )
                messages.append(ChatMessage(role: "assistant", content: reply))
                if ttsEnabled {
                    ttsManager.speak(text: reply, language: ttsLanguage, rate: ttsRate)
                }
            } catch {
                errorMessage = error.localizedDescription
            }
            isProcessing = false
        }
    }

    func toggleRecording() {
        if speechManager.isRecording {
            speechManager.stopRecording()
            let text = speechManager.transcribedText
            if !text.isEmpty { sendMessage(text) }
        } else {
            ttsManager.stop()
            try? speechManager.startRecording()
        }
    }

    func clearConversation() {
        messages = []
        errorMessage = nil
        ttsManager.stop()
        if speechManager.isRecording { speechManager.stopRecording() }
    }
}
