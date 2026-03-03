import Foundation
import SwiftData

struct WeatherData: Codable, Sendable {
    let current: Current

    struct Current: Codable, Sendable {
        let time: Date
        let rain: Float
        let temperature2m: Float
    }
}

@Model
final class WeatherDataModel {
    var currentTime: Date
    var rain: Float
    var temperature2m: Float

    init(currentTime: Date, rain: Float, temperature2m: Float) {
        self.currentTime = currentTime
        self.rain = rain
        self.temperature2m = temperature2m
    }

    convenience init(from data: WeatherData) {
        self.init(
            currentTime: data.current.time,
            rain: data.current.rain,
            temperature2m: data.current.temperature2m
        )
    }
}
