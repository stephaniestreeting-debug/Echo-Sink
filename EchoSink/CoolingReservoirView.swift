import SwiftUI
import SwiftData

struct CoolingReservoirView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Draft.unlockAt) private var drafts: [Draft]

    var body: some View {
        NavigationStack {
            Group {
                if drafts.isEmpty {
                    ContentUnavailableView(
                        "Nothing sinking",
                        systemImage: "water.waves",
                        description: Text("Drafts you sink will cool here until they're ready.")
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 14) {
                            ForEach(drafts) { draft in
                                DraftCard(draft: draft, onDelete: { delete(draft) })
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .background(Color("BackgroundPrimary").ignoresSafeArea())
            .navigationTitle("Cooling Reservoir")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func delete(_ draft: Draft) {
        NotificationManager.cancelUnlockNotification(for: draft)
        withAnimation {
            modelContext.delete(draft)
        }
    }
}

private struct DraftCard: View {
    let draft: Draft
    let onDelete: () -> Void
    @State private var showSinkAnimation = false
    @State private var showCopiedConfirmation = false

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let unlocked = draft.unlockAt <= context.date

            VStack(alignment: .leading, spacing: 12) {
                if unlocked {
                    Text(draft.text)
                        .font(.system(.body, design: .serif))
                        .transition(.blurReplace)
                } else {
                    Text(draft.text)
                        .font(.system(.body, design: .serif))
                        .blur(radius: 9)
                        .redacted(reason: .placeholder)
                }

                LiquidProgressView(progress: draft.progress, isReady: unlocked)

                HStack {
                    Label(
                        unlocked ? "Ready" : timeRemainingLabel(until: draft.unlockAt, from: context.date),
                        systemImage: unlocked ? "checkmark.circle.fill" : "hourglass"
                    )
                    .font(.caption)
                    .monospacedDigit()
                    .foregroundStyle(unlocked ? .green : .secondary)

                    Spacer()

                    if unlocked {
                        Button {
                            copyToClipboard()
                        } label: {
                            Label(
                                showCopiedConfirmation ? "Copied!" : "Copy",
                                systemImage: showCopiedConfirmation ? "checkmark" : "doc.on.doc"
                            )
                            .font(.subheadline)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(showCopiedConfirmation ? .green : Color("AccentSink"))
                        .animation(.easeInOut(duration: 0.2), value: showCopiedConfirmation)
                    }

                    Button(role: .destructive, action: onDelete) {
                        Image(systemName: "trash")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color("CardSurface"))
            )
            .overlay(alignment: .top) {
                if showSinkAnimation {
                    SinkingParticlesView()
                        .offset(y: -28)
                        .allowsHitTesting(false)
                }
            }
            .animation(.easeInOut(duration: 0.5), value: unlocked)
            .onChange(of: unlocked) { wasUnlocked, isUnlocked in
                if !wasUnlocked, isUnlocked {
                    HapticManager.unlock()
                }
            }
            .onAppear {
                guard !draft.hasPlayedSinkAnimation else { return }
                draft.hasPlayedSinkAnimation = true
                showSinkAnimation = true
            }
        }
    }

    private func copyToClipboard() {
        UIPasteboard.general.string = draft.text
        HapticManager.success()
        showCopiedConfirmation = true

        Task {
            try? await Task.sleep(for: .seconds(1.5))
            showCopiedConfirmation = false
        }
    }

    private func timeRemainingLabel(until date: Date, from now: Date) -> String {
        let remaining = max(0, date.timeIntervalSince(now))
        let hours = Int(remaining) / 3600
        let minutes = (Int(remaining) % 3600) / 60
        let seconds = Int(remaining) % 60

        if hours > 0 {
            return String(format: "%dh %02dm", hours, minutes)
        } else if minutes > 0 {
            return String(format: "%dm %02ds", minutes, seconds)
        } else {
            return String(format: "%ds", seconds)
        }
    }
}

#Preview {
    CoolingReservoirView()
        .modelContainer(for: Draft.self, inMemory: true)
}
