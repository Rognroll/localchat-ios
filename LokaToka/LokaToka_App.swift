import SwiftUI

@main
struct LokaToka_App: App {
    init() {
        // Register default values for first launch
        UserDefaults.standard.register(defaults: [
            "ollamaServerURL": "http://192.168.1.123:11434",
            "ttsEnabled": true,
            "ttsLanguage": "de-DE",
            "ttsRate": Float(0.5),
            "sttLanguage": "de-DE",
        ])
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
