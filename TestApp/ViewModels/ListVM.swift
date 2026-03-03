import Foundation
import Observation
import SwiftData

@Observable
final class ListVM {
    private let storageService: StorageServiceProtocol
    private weak var appLoadingStateObserver: AppLoadingStateObserverProtocol?

    private(set) var notes: [Note] = []
    var searchText: String = ""
    private(set) var presentedError: Error?
    private(set) var isLoading: Bool = true

    var filteredNotes: [Note] {
        guard !searchText.isEmpty else { return notes }
        return notes.filter {
            ($0.title ?? "").localizedCaseInsensitiveContains(searchText) ||
            $0.text.localizedCaseInsensitiveContains(searchText)
        }
    }

    init(
        storageService: StorageServiceProtocol,
        appLoadingStateObserver: AppLoadingStateObserverProtocol? = nil
    ) {
        self.storageService = storageService
        self.appLoadingStateObserver = appLoadingStateObserver
    }

    private static let minRuntimeSplashDuration: TimeInterval = 2.0
    private static let instantLoadThreshold: TimeInterval = 0.1

    func performInitialLoad(minDuration: TimeInterval = 0) async {
        isLoading = true
        let start = Date()
        presentedError = nil

        var delayedSplashTask: Task<Void, Never>?
        if minDuration == 0 {
            delayedSplashTask = Task { @MainActor in
                try? await Task.sleep(for: .seconds(Self.instantLoadThreshold))
                if !Task.isCancelled {
                    appLoadingStateObserver?.setAppLoading(true)
                }
            }
        }
        await loadAllNotes()

        let elapsed = Date().timeIntervalSince(start)
        if let task = delayedSplashTask, elapsed < Self.instantLoadThreshold {
            task.cancel()
        }

        if presentedError != nil {
            await MainActor.run {
                isLoading = false
                appLoadingStateObserver?.setAppLoading(false)
            }
            return
        }

        let effectiveMin: TimeInterval
        if minDuration > 0 {
            effectiveMin = minDuration
        } else if elapsed >= Self.instantLoadThreshold {
            effectiveMin = Self.minRuntimeSplashDuration
        } else {
            effectiveMin = 0
        }

        if effectiveMin > 0 {
            let remaining = effectiveMin - elapsed
            if remaining > 0 {
                try? await Task.sleep(for: .seconds(remaining))
            }
        }
        await MainActor.run {
            isLoading = false
            if minDuration == 0 {
                appLoadingStateObserver?.setAppLoading(false)
            }
        }
    }

    func clearPresentedError() {
        presentedError = nil
    }

    func loadAllNotes() async {
        presentedError = nil
        do {
            notes = try await storageService.fetchAll(Note.self)
            if notes.isEmpty { searchText = "" }
        } catch {
            presentedError = error
        }
    }

    func deleteNote(_ note: Note) async {
        presentedError = nil
        do {
            try await storageService.delete(note)
            notes.removeAll { $0.persistentModelID == note.persistentModelID }
            if notes.isEmpty { searchText = "" }
        } catch {
            presentedError = error
        }
    }

    func deleteAllNotes() async {
        presentedError = nil
        do {
            let all = try await storageService.fetchAll(Note.self)
            for note in all {
                try await storageService.delete(note)
            }
            notes = []
            searchText = ""
        } catch {
            presentedError = error
        }
    }

    func deleteNotes(_ notesToDelete: [Note]) async {
        presentedError = nil
        do {
            for note in notesToDelete {
                try await storageService.delete(note)
            }
            let idsToRemove = Set(notesToDelete.map(\.persistentModelID))
            notes.removeAll { idsToRemove.contains($0.persistentModelID) }
            if notes.isEmpty { searchText = "" }
        } catch {
            presentedError = error
        }
    }
}
