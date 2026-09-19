import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            DraftEditorView()
                .tabItem {
                    Label("Sink", systemImage: "arrow.down.circle")
                }

            CoolingReservoirView()
                .tabItem {
                    Label("Reservoir", systemImage: "water.waves")
                }
        }
        .tint(Color("AccentSink"))
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Draft.self, inMemory: true)
}
