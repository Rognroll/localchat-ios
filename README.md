# LokaToka

Voice-first iOS chat interface for local [Ollama](https://ollama.com) LLM models running on a Mac Mini (or any host) in your local network.

## Features

- **Voice input** via Apple Speech Recognition (`SFSpeechRecognizer`) — tap mic to start, tap again to stop and send
- **Voice output** via `AVSpeechSynthesizer` — assistant responses are spoken automatically
- **Text input** as fallback (keyboard)
- **German by default** (de-DE) for both STT and TTS, configurable
- **Streaming-off** chat via Ollama `/api/chat` with full conversation history
- **Settings screen**: server URL, model selector (fetched from `/api/tags`), TTS toggle/language/rate, STT language

## Requirements

- iOS 17.0+
- Xcode 15+
- Ollama running on a host reachable from your iPhone (default: `http://192.168.1.123:11434`)

## Setup

1. Clone the repo and open `LokaToka.xcodeproj` in Xcode
2. Select your development team in *Signing & Capabilities*
3. Run on a device (microphone / speech recognition require real hardware)
4. Open **Settings** (gear icon) and set your Ollama server URL + model

## Bundle ID

`de.r4r.localchat`

## Privacy permissions (Info.plist)

| Key | Description |
|-----|-------------|
| `NSMicrophoneUsageDescription` | Required for voice input |
| `NSSpeechRecognitionUsageDescription` | Required for on-device transcription |
