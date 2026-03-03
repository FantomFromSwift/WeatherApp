protocol WeatherServiceProtocol{
    func fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherData
}
