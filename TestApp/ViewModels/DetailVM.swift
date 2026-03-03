import Foundation
import Observation
import SwiftData

@Observable
final class DetailVM {
    private let storageService: StorageServiceProtocol
    let noteId: PersistentIdentifier

    private(set) var note: Note?
    private(set) var isLoading = true
    private(set) var presentedError: Error?

    init(storageService: StorageServiceProtocol, noteId: PersistentIdentifier) {
        self.storageService = storageService
        self.noteId = noteId
    }

    func clearPresentedError() {
        presentedError = nil
    }

    func loadNote() async {
        isLoading = true
        presentedError = nil
        defer { isLoading = false }
        do {
            let id = noteId
            let predicate = #Predicate<Note> { $0.persistentModelID == id }
            let fetched: [Note] = try await storageService.fetch(Note.self, where: predicate)
            note = fetched.first
        } catch {
            presentedError = error
        }
    }

    func deleteNote() async {
        guard let noteToDelete = note else { return }
        presentedError = nil
        do {
            try await storageService.delete(noteToDelete)
            note = nil
        } catch {
            presentedError = error
        }
    }
}
