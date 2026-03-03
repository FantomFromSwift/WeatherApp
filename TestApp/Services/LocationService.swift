import Foundation
import CoreLocation

final class LocationService: NSObject, LocationServiceProtocol {
    private let locationManager = CLLocationManager()
    private var authContinuation: CheckedContinuation<Void, Error>?
    private var locationContinuation: CheckedContinuation<CLLocationCoordinate2D, Error>?
    private var authorizationChangeHandler: ((Bool, Bool) -> Void)?
    private var previousAuthorizationStatus: CLAuthorizationStatus = .notDetermined

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        previousAuthorizationStatus = locationManager.authorizationStatus
    }

    func requestWhenInUseAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }

    func hasLocationAuthorization() -> Bool {
        let status = locationManager.authorizationStatus
        return status == .authorizedWhenInUse || status == .authorizedAlways
    }

    func setAuthorizationChangeHandler(_ handler: @escaping (Bool, Bool) -> Void) {
        authorizationChangeHandler = handler
    }
    
    func getCurrentLocation() async throws -> CLLocationCoordinate2D {
        let servicesEnabled = await Task.detached {
            CLLocationManager.locationServicesEnabled()
        }.value
        
        guard servicesEnabled else {
            throw LocationErrors.servicesDisabled
        }
        
        var status = locationManager.authorizationStatus
        if status == .notDetermined {
            try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
                authContinuation = cont
                DispatchQueue.main.async { [weak self] in
                    self?.locationManager.requestWhenInUseAuthorization()
                }
            }
            status = locationManager.authorizationStatus
        }
        
        guard status == .authorizedWhenInUse || status == .authorizedAlways else {
            throw LocationErrors.noLocation
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            locationContinuation = continuation
            DispatchQueue.main.async { [weak self] in
                self?.locationManager.requestLocation()
            }
        }
    }

    func getLocalityName(for coordinate: CLLocationCoordinate2D) async throws -> String {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let placemarks = try await CLGeocoder().reverseGeocodeLocation(location)
        guard let place = placemarks.first else {
            throw LocationErrors.localityUnavailable
        }
        if let locality = place.locality, !locality.isEmpty {
            return locality
        }
        if let area = place.administrativeArea, !area.isEmpty {
            return area
        }
        if let country = place.country, !country.isEmpty {
            return country
        }
        throw LocationErrors.localityUnavailable
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        let previousGranted = previousAuthorizationStatus == .authorizedWhenInUse || previousAuthorizationStatus == .authorizedAlways
        let currentGranted = status == .authorizedWhenInUse || status == .authorizedAlways
        previousAuthorizationStatus = status

        if let cont = authContinuation {
            authContinuation = nil
            if currentGranted {
                cont.resume()
            } else {
                cont.resume(throwing: LocationErrors.noLocation)
            }
        }

        authorizationChangeHandler?(previousGranted, currentGranted)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            locationContinuation?.resume(throwing: LocationErrors.noLocation)
            locationContinuation = nil
            return
        }
        locationContinuation?.resume(returning: location.coordinate)
        locationContinuation = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationContinuation?.resume(throwing: error)
        locationContinuation = nil
    }
}
