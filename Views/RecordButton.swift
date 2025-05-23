import SwiftUI
import SwiftSpeech

struct RecordButton: View {
    @Environment(\.isProcessing) var isProcessing: Bool
    @Environment(\.swiftSpeechState) var state: SwiftSpeech.State
    @SpeechRecognitionAuthStatus var authStatus
    
    var body: some View {
        if isProcessing {
            ZStack {
                Circle()
                    .stroke(lineWidth: 1)
                    .foregroundStyle(.separator)
                ProgressView()
                    .accessibilityLabel("Processing")
            }
            .frame(width: 100, height: 100)
        } else {
            ZStack {
                switch state {
                    case .pending:
                        Circle()
                            .stroke(lineWidth: 1)
                            .foregroundStyle(.separator)
                        Label("Start Recording", systemImage: "mic")
                            .labelStyle(.iconOnly)
                    case .recording:
                        Circle()
                            .foregroundStyle(.red)
                        Label("Stop Recording", systemImage: "waveform")
                            .labelStyle(.iconOnly)
                            .foregroundStyle(.white)
                    case .cancelling:
                        Label("Cancelling", systemImage: "xmark")
                            .labelStyle(.iconOnly)
                            .foregroundStyle(.white)
                        Circle()
                            .foregroundStyle(.tertiary)
                }
            }
            .frame(width: 100, height: 100)
        }
    }
}

#Preview {
    VStack {
        RecordButton()
            .swiftSpeechToggleRecordingOnTap(locale: Locale.current, animation: .snappy)
            .environment(\.isProcessing, false)
    }
}
