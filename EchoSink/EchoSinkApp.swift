import SwiftUI
import SwiftData

@main
struct EchoSinkApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Draft.self)
    }
}
