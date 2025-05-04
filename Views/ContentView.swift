import SwiftUI
import SwiftSpeech
import Foundation

extension EnvironmentValues {
    @Entry var isProcessing: Bool = false
}

extension View {
    func isProcessing(_ isProcessing: Bool) -> some View {
        environment(\.isProcessing, isProcessing)
    }
}

struct ContentView: View {
    @State var text = "Nothing recorded"
    @State var answer = ""
    @State var locale = Locale(identifier: "de-DE")
    @State var url = "http://192.168.211.60:3000/app/"
    @State var isProcessing = false
    
    var body: some View {
        VStack(alignment: .center) {
            SwiftSpeech.RecordButton()
                .swiftSpeechToggleRecordingOnTap(locale: locale, animation: .snappy)
                .isProcessing(isProcessing)
                .onAppear {
                    SwiftSpeech.requestSpeechRecognitionAuthorization()
                }
                .onRecognizeLatest(update: $text)
                .onStopRecording { _ in
                    isProcessing = true
                    Task {
                        do {
                            let result = try await fetchHint(userInput: text)
                            await MainActor.run {
                                answer = result
                            }
                        } catch {
                            let result = "\(error)"
                            await MainActor.run {
                                answer = result
                            }
                        }
                    }
                    isProcessing = false
                }
            Text(text)
            if isProcessing {
                ProgressView("Processing")
            } else {
                Text(answer)
            }
#if DEBUG
            TextField("URL", text: $url)
                .padding()
                .background(.quaternary, in: .capsule)
#endif
        }
        .padding(.horizontal)
    }
    
    enum HintFetchError: Error {
        case encodeFailed
        case unexpectedResponse(URLResponse)
    }
    
    func fetchHint(userInput: String) async throws -> String {
        guard let url = URL(string: self.url)?.appending(queryItems: [URLQueryItem(name: "input", value: userInput)]) else {
            throw HintFetchError.encodeFailed
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw HintFetchError.unexpectedResponse(response)
        }
        return String(decoding: data, as: UTF8.self)
    }
}
