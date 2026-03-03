import SwiftUI
import SwiftData

struct NoteCell: View {
    let note: Note

    private var temperatureText: String? {
        guard let weather = note.weather else { return nil }
        let value = Int(round(weather.temperature2m))
        return "\(value)°"
    }

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(note.text)
                    .lineLimit(2)
                if let temp = temperatureText {
                    Text(temp)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                HStack(spacing: 4) {
                    Text(note.timestamp, style: .date)
                    Text(note.timestamp, style: .time)
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            weatherIconView
        }
    }
    
    @ViewBuilder
    private var weatherIconView: some View {
        if let weather = note.weather {
            if weather.rain > 0 {
                Image(systemName: "cloud.rain.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: adaptyW(50), height: adaptyH(50))
                    .foregroundStyle(Color.blue.gradient)
            } else if note.timestamp.isNightByCreationTime {
                Image(systemName: "moon.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: adaptyW(50), height: adaptyH(50))
                    .foregroundStyle(Color.purple.gradient)
            } else {
                Image(systemName: "sun.max.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: adaptyW(50), height: adaptyH(50))
                    .foregroundStyle(Color.yellow.gradient)
            }
        }
    }
}
