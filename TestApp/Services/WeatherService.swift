import Foundation
import OpenMeteoSdk

final class WeatherService: WeatherServiceProtocol {
    private func buildURL(latitude: Double, longitude: Double) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.open-meteo.com"
        components.path = "/v1/forecast"

        components.queryItems = [
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(name: "hourly", value: "temperature_2m"),
            URLQueryItem(name: "current", value: "rain,temperature_2m"),
            URLQueryItem(name: "format", value: "flatbuffers")
        ]

        return components.url
    }
    
    func fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherData {
        guard let url = buildURL(latitude: latitude, longitude: longitude) else {
            throw URLErrors.invalidURL
        }

        do {
            let responses = try await WeatherApiResponse.fetch(url: url)

            guard let response = responses.first else {
                throw URLErrors.invalidResponse
            }

            let utcOffsetSeconds = response.utcOffsetSeconds

            guard let current = response.current else {
                throw URLErrors.invalidResponse
            }

            let currentTime = Date(timeIntervalSince1970: TimeInterval(current.time + Int64(utcOffsetSeconds)))

            guard let rainValue = current.variables(at: 0)?.value,
                  let tempValue = current.variables(at: 1)?.value else {
                throw URLErrors.invalidResponse
            }

            let currentModel = WeatherData.Current(
                time: currentTime,
                rain: rainValue,
                temperature2m: tempValue
            )
            
            return WeatherData(current: currentModel)

        } catch {
            throw mapError(error)
        }
    }

    private func mapError(_ error: Error) -> URLErrors {
        if let handlerError = error as? URLErrors {
            return handlerError
        }
        
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet:
                return .noInternet
            case .badURL:
                return .invalidURL
            default:
                return .invalidRequest
            }
        }
        return .invalidResponse
    }
}
