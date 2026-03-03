import Foundation

extension Error {
    var alertTitle: String {
        (self as? LocalizedError)?.errorDescription ?? localizedDescription
    }

    var alertRecoveryMessage: String? {
        (self as? LocalizedError)?.recoverySuggestion
    }
}
