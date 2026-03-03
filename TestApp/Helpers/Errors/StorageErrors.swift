import Foundation

enum StorageErrors: Error {
    case saveFailed(String)
    case deleteFailed(String)
    case fetchFailed(String)
}

extension StorageErrors: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .saveFailed(let msg):
            return "Failed to save object: \(msg)"
        case .deleteFailed(let msg):
            return "Failed to delete object: \(msg)"
        case .fetchFailed(let msg):
            return "Failed to fetch objects: \(msg)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .saveFailed(_):
            return "Try saving again or check storage availability."
        case .deleteFailed(_):
            return "Try deleting again or check if object exists."
        case .fetchFailed(_):
            return "Try fetching again later."
        }
    }
}
