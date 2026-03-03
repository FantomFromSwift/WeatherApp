import SwiftUI
import SwiftData

struct DetailView: View {
    @Bindable var vm: DetailVM

    var body: some View {
        Group {
            switch (vm.isLoading, vm.note) {
            case (true, _):
                ProgressView()
            case (false, let note?):
                Form {
                    Section("Text") {
                        Text(note.text)
                    }
                    Section("Date") {
                        HStack(spacing: 8) {
                            Text(note.timestamp, style: .date)
                            Text(note.timestamp, style: .time)
                        }
                    }
                    if let weather = note.weather {
                        if let locality = note.localityName, !locality.isEmpty {
                            Section("Location") {
                                Text(locality)
                            }
                        }
                        Section("Weather") {
                            HStack {
                                HStack(spacing: 10){
                                    Text("\(Int(weather.temperature2m.rounded()))°")
                                        .font(.title.bold())
                                    VStack(alignment: .leading, spacing: 5){
                                        Text(weather.temperature2m > 10 ? "Warm" : "Cold" )
                                            .font(.headline.bold())
                                            .foregroundStyle(.primary)
                                        Text(weatherConditionText(rain: weather.rain, isNight: note.timestamp.isNightByCreationTime))
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                    .multilineTextAlignment(.leading)
                                }
                                
                                Spacer()
                                Image(systemName: weatherIconName(rain: weather.rain, isNight: note.timestamp.isNightByCreationTime))
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: adaptyW(75), height: adaptyH(74))
                                    .foregroundStyle(weatherIconColor(rain: weather.rain, isNight: note.timestamp.isNightByCreationTime))
                            }
                        }
                    }
                    Section {
                        Button(role: .destructive) {
                            Task { await vm.deleteNote() }
                        } label: {
                            Label("Delete note", systemImage: "trash")
                                .foregroundStyle(.red)
                        }
                    }
                }
            case (false, nil):
                ContentUnavailableView("Note not found", systemImage: "note.text")
            }
        }
        .navigationTitle("Note")
        .task { @MainActor in
            await vm.loadNote()
        }
        .errorAlert(error: vm.presentedError, onDismiss: vm.clearPresentedError)
    }

    private func weatherConditionText(rain: Float, isNight: Bool) -> String {
        if rain > 0 { return "Rainy" }
        return isNight ? "Moonly" : "Sunny"
    }

    private func weatherIconName(rain: Float, isNight: Bool) -> String {
        if rain > 0 { return "cloud.rain.fill" }
        return isNight ? "moon.fill" : "sun.max.fill"
    }

    private func weatherIconColor(rain: Float, isNight: Bool) -> AnyShapeStyle {
        if rain > 0 { return AnyShapeStyle(Color.blue.gradient) }
        return isNight ? AnyShapeStyle(Color.purple.gradient) : AnyShapeStyle(Color.yellow.gradient)
    }
}
