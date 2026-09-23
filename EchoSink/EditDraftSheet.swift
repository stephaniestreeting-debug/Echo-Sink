import SwiftUI

struct EditDraftSheet: View {
    let draft: Draft
    let onResink: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var editedText: String
    @State private var preset: CoolingPreset = .oneHour

    init(draft: Draft, onResink: @escaping () -> Void) {
        self.draft = draft
        self.onResink = onResink
        _editedText = State(initialValue: draft.text)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color("CardSurface"))

                    TextEditor(text: $editedText)
                        .font(.system(.title3, design: .serif))
                        .lineSpacing(6)
                        .scrollContentBackground(.hidden)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 18)
                }
                .padding(.horizontal, 20)

                VStack(spacing: 14) {
                    Text("Let it cool a little longer?")
                        .font(.system(.subheadline, design: .serif))
                        .foregroundStyle(.secondary)

                    Picker("Cooling period", selection: $preset) {
                        ForEach(CoolingPreset.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)

                    Button("Sink It Again", action: resink)
                        .buttonStyle(SinkButtonStyle(isEnabled: isTextValid))
                        .disabled(!isTextValid)

                    Button("Keep It Ready As Is", action: keepReady)
                        .font(.system(.subheadline, design: .serif))
                        .foregroundStyle(.secondary)
                        .disabled(!isTextValid)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
            .background(Color("BackgroundPrimary").ignoresSafeArea())
            .navigationTitle("Edit Draft")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private var isTextValid: Bool {
        !editedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func resink() {
        guard isTextValid else { return }
        draft.resink(text: editedText, duration: preset.duration)
        NotificationManager.scheduleUnlockNotification(for: draft)
        HapticManager.sink()
        onResink()
        dismiss()
    }

    private func keepReady() {
        guard isTextValid else { return }
        draft.text = editedText
        dismiss()
    }
}
