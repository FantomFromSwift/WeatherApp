import SwiftUI
import SwiftData

struct ListView: View {
    @Environment(DIContainer.self) var container
    @Bindable var vm: ListVM
    @Binding var isAddNotePresented: Bool
    @State private var addNoteError: Error?
    @State private var isSearchPresented: Bool = false
    @State private var isSelectionMode = false
    @State private var selectedNoteIDs: Set<PersistentIdentifier> = []
    @State private var showDeleteSelectedAlert = false
    @State private var showDeleteAllAlert = false

    var body: some View {
        mainContent
        .modifier(SearchableWhenNotEmptyModifier(
            isActive: !vm.notes.isEmpty,
            searchText: $vm.searchText,
            isSearchPresented: $isSearchPresented
        ))
        .navigationTitle("Notes")
        .navigationDestination(for: PersistentIdentifier.self) { id in
            DetailView(vm: container.makeDetailVM(noteId: id))
        }
        .task { @MainActor in
            await vm.performInitialLoad(minDuration: 0)
        }
        .fullScreenCover(isPresented: $isAddNotePresented, onDismiss: {
            Task { @MainActor in await vm.loadAllNotes() }
        }, content: {
            NavigationStack {
                AddNoteView(vm: container.makeAddNoteVM(
                    onSaveError: { error in
                        Task { @MainActor in
                            container.setAppLoading(false)
                            addNoteError = error
                        }
                    },
                    onSaveSuccess: { Task { @MainActor in await vm.loadAllNotes() } }
                ))
            }
        })
        .errorAlert(error: addNoteError ?? vm.presentedError, onDismiss: {
            container.setAppLoading(false)
            addNoteError = nil
            vm.clearPresentedError()
        })
    }

    @ViewBuilder
    private var listContent: some View {
        if isSelectionMode {
            List {
                ForEach(vm.filteredNotes) { note in
                    let id = note.persistentModelID
                    let isSelected = selectedNoteIDs.contains(id)
                    Button {
                        if isSelected {
                            selectedNoteIDs.remove(id)
                        } else {
                            selectedNoteIDs.insert(id)
                        }
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(isSelected ? Color.accentColor : .secondary)
                            NoteCell(note: note)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        } else {
            List {
                ForEach(vm.filteredNotes) { note in
                    NavigationLink(value: note.persistentModelID) {
                        NoteCell(note: note)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            Task { await vm.deleteNote(note) }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
    }

    private func deleteSelectedNotes() {
        let toDelete = vm.notes.filter { selectedNoteIDs.contains($0.persistentModelID) }
        guard !toDelete.isEmpty else { return }
        selectedNoteIDs = []
        isSelectionMode = false
        Task { await vm.deleteNotes(toDelete) }
    }

    @ViewBuilder
    private var mainContent: some View {
        Group {
            switch vm.notes.isEmpty {
            case true:
                ContentUnavailableView {
                    Label("No Notes", systemImage: "list.bullet.rectangle.portrait")
                } description: {
                    Text("Add a note to get started. Your note will be saved with the current weather.")
                } actions: {
                    Button("Add note") {
                        isAddNotePresented = true
                    }
                }
                .offset(y: -60)
            case false:
                listContent
                .toolbar {
                    if isSelectionMode {
                        ToolbarItemGroup(placement: .topBarLeading) {
                                Button("Done") {
                                    isSelectionMode = false
                                    selectedNoteIDs = []
                                }
                            
                                Button("Select All") {
                                    selectedNoteIDs = Set(vm.notes.map(\.persistentModelID))
                                }
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            if !selectedNoteIDs.isEmpty {
                                Button(role: .destructive) {
                                    showDeleteSelectedAlert = true
                                } label: {
                                    Image(systemName: "trash")
                                        .foregroundStyle(.red)
                                }
                            }
                        }
                    } else {
                        ToolbarItemGroup(placement: .topBarTrailing) {
                            Button {
                                isAddNotePresented = true
                            } label: {
                                Image(systemName: "plus")
                            }
                        }
                        ToolbarItem(placement: .topBarLeading) {
                            Menu {
                                Button {
                                    isSelectionMode = true
                                } label: {
                                    Label("Select", systemImage: "checkmark.circle")
                                }
                                Button(role: .destructive) {
                                    showDeleteAllAlert = true
                                } label: {
                                    Label("Delete all", systemImage: "trash")
                                        .foregroundStyle(.red)
                                }
                            } label: {
                                Image(systemName: "ellipsis.circle")
                            }
                        }
                    }
                }
                .alert("Delete selected notes?", isPresented: $showDeleteSelectedAlert) {
                    Button("Cancel", role: .cancel) {}
                    Button("Delete", role: .destructive) {
                        deleteSelectedNotes()
                    }
                } message: {
                    Text("Are you sure you want to delete the selected notes?")
                }
                .alert("Delete all notes?", isPresented: $showDeleteAllAlert) {
                    Button("Cancel", role: .cancel) {}
                    Button("Delete All", role: .destructive) {
                        Task { await vm.deleteAllNotes() }
                    }
                } message: {
                    Text("Are you sure you want to delete all notes? This cannot be undone.")
                }
            }
        }
    }
}


private struct SearchableWhenNotEmptyModifier: ViewModifier {
    let isActive: Bool
    @Binding var searchText: String
    @Binding var isSearchPresented: Bool

    func body(content: Content) -> some View {
        if isActive {
            content.searchable(
                text: $searchText,
                isPresented: $isSearchPresented,
                placement: .automatic,
                prompt: "Search notes"
            )
        } else {
            content
        }
    }
}
