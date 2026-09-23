import SwiftUI
import SwiftData

enum CoolingPreset: String, CaseIterable, Identifiable {
    case fifteenMinutes = "15m"
    case oneHour = "1h"
    case fourHours = "4h"
    case oneDay = "24h"

    var id: String { rawValue }

    var duration: TimeInterval {
        switch self {
        case .fifteenMinutes: 15 * 60
        case .oneHour: 60 * 60
        case .fourHours: 4 * 60 * 60
        case .oneDay: 24 * 60 * 60
        }
    }
}

struct DraftEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var draftText: String = ""
    @State private var draftLabel: String = ""
    @State private var preset: CoolingPreset = .oneHour
    @State private var didSink = false
    @State private var isSinking = false
    @State private var showSunkConfirmation = false
    @FocusState private var isEditorFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("THE ECHO SINK")
                        .font(.system(.caption, design: .serif))
                        .tracking(3)
                        .foregroundStyle(Color("AccentSink"))
                    Text("Write it. Let it settle.")
                        .font(.system(.title2, design: .serif))
                        .foregroundStyle(.primary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 12)

                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color("CardSurface"))
                        .shadow(color: .black.opacity(0.08), radius: 12, y: 6)

                    TextEditor(text: $draftText)
                        .focused($isEditorFocused)
                        .font(.system(.title3, design: .serif))
                        .lineSpacing(6)
                        .scrollContentBackground(.hidden)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 18)

                    if draftText.isEmpty {
                        Text("Say the thing you shouldn't send yet.")
                            .font(.system(.title3, design: .serif))
                            .foregroundStyle(.tertiary)
                            .padding(.horizontal, 22)
                            .padding(.top, 24)
                            .allowsHitTesting(false)
                    }
                }
                .padding(.horizontal, 20)
                .scaleEffect(isSinking ? 0.86 : 1)
                .offset(y: isSinking ? 60 : 0)
                .opacity(isSinking ? 0 : 1)
                .blur(radius: isSinking ? 6 : 0)

                VStack(spacing: 16) {
                    TextField("Label it (optional) — e.g. \"Work email\"", text: $draftLabel)
                        .font(.system(.subheadline, design: .serif))
                        .padding(.horizontal, 20)

                    Picker("Cooling period", selection: $preset) {
                        ForEach(CoolingPreset.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 20)

                    Button("Sink It", action: sinkDraft)
                        .buttonStyle(SinkButtonStyle(isEnabled: !draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty))
                        .disabled(draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)
                        .sensoryFeedback(.impact(weight: .heavy), trigger: didSink)
                }
            }
            .background(Color("BackgroundPrimary").ignoresSafeArea())
            .toolbar(.hidden)
            .overlay(alignment: .top) {
                if showSunkConfirmation {
                    Text("Sunk — cooling for \(preset.rawValue)")
                        .font(.system(.subheadline, design: .serif))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Capsule().fill(Color("AccentSink")))
                        .foregroundStyle(Color("BackgroundPrimary"))
                        .padding(.top, 60)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
        }
    }

    private func sinkDraft() {
        let trimmed = draftText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let draft = Draft(
            text: draftText,
            label: draftLabel.trimmingCharacters(in: .whitespacesAndNewlines),
            duration: preset.duration
        )
        modelContext.insert(draft)
        NotificationManager.scheduleUnlockNotification(for: draft)

        HapticManager.sink()
        didSink.toggle()
        isEditorFocused = false

        withAnimation(.easeIn(duration: 0.45)) {
            isSinking = true
            showSunkConfirmation = true
        }

        Task {
            try? await Task.sleep(for: .milliseconds(460))
            draftText = ""
            draftLabel = ""
            isSinking = false
        }

        Task {
            try? await Task.sleep(for: .seconds(2.2))
            withAnimation {
                showSunkConfirmation = false
            }
        }
    }
}

#Preview {
    DraftEditorView()
        .modelContainer(for: Draft.self, inMemory: true)
}
