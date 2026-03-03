import Foundation
import Observation

@Observable
final class AddNoteVM {
    private let getWeatherUC: GetWeatherUCProtocol
    private weak var weatherInclusionPolicy: WeatherInclusionPolicyProtocol?
    private weak var appLoadingStateObserver: AppLoadingStateObserverProtocol?

    var noteText = ""
    private(set) var isSaving = false
    private(set) var presentedError: Error?
    private(set) var didSaveSuccessfully = false

    private static let minSplashDuration: TimeInterval = 2.0
    private static let instantThreshold: TimeInterval = 0.1

    private let onSaveError: (@Sendable (Error) -> Void)?
    private let onSaveSuccess: (@Sendable () -> Void)?

    init(
        getWeatherUC: GetWeatherUCProtocol,
        weatherInclusionPolicy: WeatherInclusionPolicyProtocol,
        appLoadingStateObserver: AppLoadingStateObserverProtocol? = nil,
        onSaveError: (@Sendable (Error) -> Void)? = nil,
        onSaveSuccess: (@Sendable () -> Void)? = nil
    ) {
        self.getWeatherUC = getWeatherUC
        self.weatherInclusionPolicy = weatherInclusionPolicy
        self.appLoadingStateObserver = appLoadingStateObserver
        self.onSaveError = onSaveError
        self.onSaveSuccess = onSaveSuccess
    }

    var includeWeatherInSave: Bool { weatherInclusionPolicy?.shouldIncludeWeather ?? false }

    func clearPresentedError() {
        presentedError = nil
    }

    func saveNote() async {
        let text = noteText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else {
            struct EmptyNoteError: LocalizedError {
                var errorDescription: String? { "Note text cannot be empty" }
                var recoverySuggestion: String? { "Enter some text in the note field before saving." }
            }
            let err = EmptyNoteError()
            presentedError = err
            await MainActor.run { onSaveError?(err) }
            return
        }
        isSaving = true
        presentedError = nil
        didSaveSuccessfully = false

        let start = Date()
        var delayedSplashTask: Task<Void, Never>?
        delayedSplashTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(Self.instantThreshold))
            if !Task.isCancelled {
                appLoadingStateObserver?.setAppLoading(true)
            }
        }

        do {
            let includeWeather = weatherInclusionPolicy?.shouldIncludeWeather ?? false
            try await getWeatherUC.saveNote(noteText: text, includeWeather: includeWeather)
        } catch {
            await MainActor.run {
                isSaving = false
                presentedError = error
                appLoadingStateObserver?.setAppLoading(false)
                onSaveError?(error)
            }
            return
        }

        let elapsed = Date().timeIntervalSince(start)
        if let task = delayedSplashTask, elapsed < Self.instantThreshold {
            task.cancel()
        }

        let effectiveMin = elapsed >= Self.instantThreshold ? Self.minSplashDuration : 0
        if effectiveMin > 0 {
            let remaining = effectiveMin - elapsed
            if remaining > 0 {
                try? await Task.sleep(for: .seconds(remaining))
            }
        }

        await MainActor.run {
            isSaving = false
            noteText = ""
            didSaveSuccessfully = true
            appLoadingStateObserver?.setAppLoading(false)
            onSaveSuccess?()
        }
    }
}
