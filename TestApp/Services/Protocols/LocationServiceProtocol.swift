import CoreLocation

protocol LocationServiceProtocol {
    func requestWhenInUseAuthorization()
    func getCurrentLocation() async throws -> CLLocationCoordinate2D
    func getLocalityName(for coordinate: CLLocationCoordinate2D) async throws -> String
    func hasLocationAuthorization() -> Bool
    func setAuthorizationChangeHandler(_ handler: @escaping (Bool, Bool) -> Void)
}
