import Foundation

enum URLErrors: Error{
    case noInternet
    case invalidRequest
    case invalidResponse
    case invalidURL
}

extension URLErrors: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .noInternet:
            return "No internet connection. Please check your network settings and try again."
            
        case .invalidRequest:
            return "The request could not be completed. Please try again later."
            
        case .invalidResponse:
            return "The server returned an invalid response. Please try again later."
            
        case .invalidURL:
            return "The request URL is invalid. Please contact support if the issue persists."
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .noInternet:
            return "Make sure you are connected to Wi-Fi or mobile data."
            
        case .invalidRequest:
            return "Retry the action in a few moments."
            
        case .invalidResponse:
            return "Wait a few minutes and try again."
            
        case .invalidURL:
            return "Restart the app and try again."
        }
    }
}
