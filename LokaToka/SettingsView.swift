import SwiftUI

struct SettingsView: View {
    @AppStorage("ollamaServerURL") private var serverURL = "http://192.168.1.123:11434"
    @AppStorage("ollamaModel")    private var selectedModel = ""
    @AppStorage("ttsEnabled")    private var ttsEnabled = true
    @AppStorage("ttsLanguage")   private var ttsLanguage = "de-DE"
    @AppStorage("ttsRate")       private var ttsRate = 0.5
    @AppStorage("sttLanguage")   private var sttLanguage = "de-DE"

    @State private var availableModels: [OllamaModel] = []
    @State private var isLoadingModels = false
    @State private var modelLoadError: String?

    @Environment(\.dismiss) private var dismiss

    private let languages: [(String, String)] = [
        ("de-DE", "Deutsch"),
        ("en-US", "English (US)"),
        ("en-GB", "English (UK)"),
        ("fr-FR", "Français"),
        ("es-ES", "Español"),
        ("it-IT", "Italiano"),
        ("ja-JP", "日本語"),
        ("zh-CN", "中文 (简体)"),
    ]

    var body: some View {
        NavigationStack {
            Form {
                serverSection
                modelSection
                ttsSection
                sttSection
            }
            .navigationTitle("Einstellungen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fertig") { dismiss() }
                }
            }
            .task { await loadModels() }
        }
    }

    // MARK: - Sections

    private var serverSection: some View {
        Section("Ollama Server") {
            TextField("Server URL", text: $serverURL)
                .keyboardType(.URL)
                .autocapitalization(.none)
                .autocorrectionDisabled()
                .textContentType(.URL)
        }
    }

    private var modelSection: some View {
        Section("Modell") {
            HStack {
                Picker("Modell", selection: $selectedModel) {
                    Text("— Kein Modell —").tag("")
                    ForEach(availableModels) { model in
                        Text(model.name).tag(model.name)
                    }
                }
                if isLoadingModels {
                    Spacer()
                    ProgressView()
                }
            }

            Button {
                Task { await loadModels() }
            } label: {
                Label("Modelle neu laden", systemImage: "arrow.clockwise")
            }

            if let error = modelLoadError {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }

    private var ttsSection: some View {
        Section("Sprachausgabe (TTS)") {
            Toggle("Aktiviert", isOn: $ttsEnabled)

            if ttsEnabled {
                Picker("Sprache", selection: $ttsLanguage) {
                    ForEach(languages, id: \.0) { Text($0.1).tag($0.0) }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Geschwindigkeit: \(String(format: "%.1f", ttsRate))")
                        .font(.subheadline)
                    Slider(value: $ttsRate, in: 0.1...0.9, step: 0.05)
                }
            }
        }
    }

    private var sttSection: some View {
        Section("Spracheingabe (STT)") {
            Picker("Sprache", selection: $sttLanguage) {
                ForEach(languages, id: \.0) { Text($0.1).tag($0.0) }
            }
        }
    }

    // MARK: - Actions

    private func loadModels() async {
        isLoadingModels = true
        modelLoadError = nil
        do {
            let models = try await OllamaService.shared.fetchModels(serverURL: serverURL)
            availableModels = models
            if selectedModel.isEmpty, let first = models.first {
                selectedModel = first.name
            }
        } catch {
            modelLoadError = error.localizedDescription
        }
        isLoadingModels = false
    }
}

#Preview {
    SettingsView()
}
