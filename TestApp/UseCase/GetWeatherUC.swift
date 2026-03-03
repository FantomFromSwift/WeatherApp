import Foundation
import CoreLocation

protocol GetWeatherUCProtocol {
    func saveNote(noteText: String, includeWeather: Bool) async throws
}

final class GetWeatherUC: GetWeatherUCProtocol {
    private let networkService: NetworkServiceProtocol
    private let locationService: LocationServiceProtocol
    private let weatherService: WeatherServiceProtocol
    private let storageService: StorageServiceProtocol

    init(
        networkService: NetworkServiceProtocol,
        locationService: LocationServiceProtocol,
        weatherService: WeatherServiceProtocol,
        storageService: StorageServiceProtocol
    ) {
        self.networkService = networkService
        self.locationService = locationService
        self.weatherService = weatherService
        self.storageService = storageService
    }

    func saveNote(noteText: String, includeWeather: Bool) async throws {
        if includeWeather {
            guard networkService.isConnected else {
                throw NetworkError.disconnected
            }

            let coordinate: CLLocationCoordinate2D
            do {
                coordinate = try await locationService.getCurrentLocation()
            } catch let error as LocationErrors {
                throw error
            } catch {
                throw LocationErrors.noLocation
            }

            let weather: WeatherData
            do {
                weather = try await weatherService.fetchWeather(
                    latitude: coordinate.latitude,
                    longitude: coordinate.longitude
                )
            } catch let error as URLErrors {
                throw error
            } catch {
                throw URLErrors.invalidResponse
            }

            let localityName = try? await locationService.getLocalityName(for: coordinate)
            try await storageService.saveNote(text: noteText, timestamp: Date(), weather: weather, localityName: localityName)
        } else {
            try await storageService.saveNote(text: noteText, timestamp: Date(), weather: nil, localityName: nil)
        }
    }
}
