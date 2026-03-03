import SwiftUI

struct Splash: View {
    @Bindable var container: DIContainer
    @State private var isActive: Bool = false
    @State private var colorMatchesActive: Bool = false
    @State private var timer: Timer?
    private static let symbolEffectDuration: Double = 0.25
    private var isNight: Bool { Date().isNightByCreationTime }

    var body: some View {
        Image(systemName: splashSymbolName)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: adaptyW(150), height: adaptyH(150))
            .foregroundStyle(splashSymbolColor)
            .contentTransition(.symbolEffect(.replace))
            .onAppear {
                colorMatchesActive = isActive
                let t = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                    Task { @MainActor in
                        isActive.toggle()
                        try? await Task.sleep(for: .seconds(Self.symbolEffectDuration))
                        colorMatchesActive = isActive
                    }
                }
                timer = t
                RunLoop.main.add(t, forMode: .common)
            }
            .onDisappear {
                timer?.invalidate()
                timer = nil
            }
    }

    private var splashSymbolName: String {
        if !container.getWeatherInfo {
            return isActive ? "list.clipboard.fill" : "list.clipboard"
        }
        if isActive {
            return isNight ? "moon.fill" : "sun.max.fill"
        }
        return "cloud.rain.fill"
    }

    private var splashSymbolColor: some ShapeStyle {
        if !container.getWeatherInfo { return Color.blue.gradient }
        if !colorMatchesActive { return Color.blue.gradient }
        return isNight ? Color.purple.gradient : Color.yellow.gradient
    }
}
