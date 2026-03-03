import SwiftUI
import SwiftData

struct AddNoteView: View {
    @Bindable var vm: AddNoteVM
    @Environment(\.dismiss) var dismiss
    var body: some View {
        Form {
            Section {
                TextField("Note text", text: $vm.noteText, axis: .vertical)
                    .lineLimit(3...6)
            }

            Section {
                Button {
                    dismiss()
                    Task { await vm.saveNote() }
                } label: {
                    Text(vm.includeWeatherInSave ? "Save with weather" : "Save")
                        .frame(maxWidth: .infinity)
                }
                .disabled(vm.noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .navigationTitle("New Note")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                }
            }
        }
    }
}
