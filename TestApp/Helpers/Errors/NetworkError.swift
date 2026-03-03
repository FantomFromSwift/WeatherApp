import Foundation

enum NetworkError: Error{
    case disconnected
}

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .disconnected:
            return "No internet connection. Please check your network settings."
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .disconnected:
            return "Make sure Wi-Fi or mobile data is enabled."
        }
    }
}
