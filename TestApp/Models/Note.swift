import Foundation
import SwiftData

@Model
final class Note {
    var title: String?
    var text: String
    var timestamp: Date
    var localityName: String?
    @Relationship(deleteRule: .cascade)
    var weather: WeatherDataModel?

    init(text: String, timestamp: Date, localityName: String? = nil, weather: WeatherDataModel?) {
        self.text = text
        self.timestamp = timestamp
        self.localityName = localityName
        self.weather = weather
    }
}
