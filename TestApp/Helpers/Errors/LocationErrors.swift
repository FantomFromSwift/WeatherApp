import Foundation

enum LocationErrors: Error {
    case servicesDisabled
    case noLocation
    case localityUnavailable
}

extension LocationErrors: LocalizedError {

    var errorDescription: String? {
        switch self {
        case .servicesDisabled:
            return "Location services are disabled. Please enable them in Settings to use this feature."
        case .noLocation:
            return "Unable to retrieve your location at the moment."
        case .localityUnavailable:
            return "Could not determine the city name for this location."
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .servicesDisabled:
            return "Go to Settings → Privacy → Location Services and turn on Location Services for this app."
        case .noLocation:
            return "Try again in a few moments or move to an open area for better GPS signal."
        case .localityUnavailable:
            return "The note will be saved without the location name."
        }
    }
}
