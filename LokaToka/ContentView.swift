import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ChatViewModel()
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                chatScrollView
                Divider()
                inputArea
            }
            .navigationTitle("LokaToka")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { viewModel.clearConversation() } label: {
                        Image(systemName: "trash")
                    }
                    .disabled(viewModel.messages.isEmpty && viewModel.errorMessage == nil)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showSettings = true } label: {
                        Image(systemName: "gear")
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }

    private var chatScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(viewModel.messages) { message in
                        MessageBubble(message: message)
                            .id(message.id)
                    }
                    if viewModel.isProcessing {
                        ProcessingBubble().id("processing")
                    }
                    if let error = viewModel.errorMessage {
                        ErrorBubble(message: error).id("error")
                    }
                    Color.clear.frame(height: 1).id("bottom")
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .onChange(of: viewModel.messages.count) { _, _ in
                withAnimation { proxy.scrollTo("bottom") }
            }
            .onChange(of: viewModel.isProcessing) { _, _ in
                withAnimation { proxy.scrollTo("bottom") }
            }
        }
    }

    private var inputArea: some View {
        VStack(spacing: 10) {
            HStack(spacing: 8) {
                TextField("Nachricht eingeben…", text: $viewModel.inputText, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(1...4)
                    .submitLabel(.send)
                    .onSubmit { viewModel.sendMessage(viewModel.inputText) }

                Button {
                    viewModel.sendMessage(viewModel.inputText)
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundColor(
                            viewModel.inputText.trimmingCharacters(in: .whitespaces).isEmpty
                                ? .secondary : .accentColor
                        )
                }
                .disabled(
                    viewModel.inputText.trimmingCharacters(in: .whitespaces).isEmpty ||
                    viewModel.isProcessing
                )
            }
            .padding(.horizontal)

            MicButton(viewModel: viewModel)
                .padding(.bottom, 12)
        }
        .padding(.top, 8)
        .background(Color(.systemBackground))
    }
}

// MARK: - Message Bubble

struct MessageBubble: View {
    let message: ChatMessage
    private var isUser: Bool { message.role == "user" }

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            if isUser { Spacer(minLength: 50) }
            Text(message.content)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(isUser ? Color.accentColor : Color(.secondarySystemBackground))
                .foregroundColor(isUser ? .white : .primary)
                .clipShape(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                )
            if !isUser { Spacer(minLength: 50) }
        }
    }
}

// MARK: - Processing Bubble

struct ProcessingBubble: View {
    @State private var dotCount = 1
    private let timer = Timer.publish(every: 0.4, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack {
            Text(String(repeating: ".", count: dotCount))
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .onReceive(timer) { _ in dotCount = dotCount % 3 + 1 }
            Spacer(minLength: 50)
        }
    }
}

// MARK: - Error Bubble

struct ErrorBubble: View {
    let message: String

    var body: some View {
        HStack {
            Label(message, systemImage: "exclamationmark.triangle.fill")
                .font(.caption)
                .foregroundColor(.red)
                .padding(10)
                .background(Color.red.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            Spacer()
        }
    }
}

// MARK: - Mic Button

struct MicButton: View {
    @ObservedObject var viewModel: ChatViewModel

    private enum MicState: Equatable {
        case idle, recording, processing

        var color: Color {
            switch self {
            case .idle:       return .accentColor
            case .recording:  return .red
            case .processing: return .orange
            }
        }
        var icon: String {
            switch self {
            case .idle:       return "mic.fill"
            case .recording:  return "stop.fill"
            case .processing: return "ellipsis"
            }
        }
    }

    private var state: MicState {
        if viewModel.isProcessing { return .processing }
        if viewModel.speechManager.isRecording { return .recording }
        return .idle
    }

    var body: some View {
        VStack(spacing: 6) {
            if viewModel.speechManager.isRecording, !viewModel.speechManager.transcribedText.isEmpty {
                Text(viewModel.speechManager.transcribedText)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .padding(.horizontal)
                    .transition(.opacity)
            }

            Button {
                viewModel.toggleRecording()
            } label: {
                ZStack {
                    Circle()
                        .fill(state.color.opacity(0.15))
                        .frame(width: 72, height: 72)
                        .scaleEffect(state == .recording ? 1.15 : 1.0)
                        .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true),
                                   value: state == .recording)
                    Circle()
                        .fill(state.color)
                        .frame(width: 58, height: 58)
                    Image(systemName: state.icon)
                        .font(.title2)
                        .foregroundColor(.white)
                }
            }
            .disabled(state == .processing)
        }
        .animation(.easeInOut(duration: 0.2), value: state)
    }
}

#Preview {
    ContentView()
}
