import SwiftUI
import StoreKit
import UIKit

private enum SettingsConstants {
    static let termsOfUseURL = URL(string: "https://www.google.com")!
    static let shareYouTubeURL = URL(string: "https://www.youtube.com")!
    static var appVersion: String {
        (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "1.0"
    }
}

struct SettingsView: View {
    @Bindable var container: DIContainer
    @Environment(\.requestReview) private var requestReview
    @Environment(\.openURL) private var openURL
    @State private var showLocationDeniedAlert = false

    private var getWeatherInfoBinding: Binding<Bool> {
        Binding(
            get: { container.getWeatherInfo },
            set: { newValue in
                if newValue {
                    if container.locationService.hasLocationAuthorization() {
                        container.getWeatherInfo = true
                    } else {
                        showLocationDeniedAlert = true
                    }
                } else {
                    container.getWeatherInfo = false
                }
            }
        )
    }

    var body: some View {
        NavigationView {
            VStack(spacing: adaptyH(40)) {
                VStack(spacing: 15){
                    Toggle(isOn: getWeatherInfoBinding) {
                        Text("Get Weather Info")
                            .font(.headline.bold())
                            .foregroundStyle(.primary)
                        Text("If you want to see the weather information, turn this on")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    Toggle(
                        container.darkMode ? "Dark Mode" : "Light mode",
                        systemImage: container.darkMode ? "moon.fill" : "sun.max.fill",
                        isOn: $container.darkMode
                    )
                    .toggleStyle(.automatic)
                }
                VStack(spacing: 15){
                    Link(destination: SettingsConstants.termsOfUseURL) {
                        Text("Terms of Use")
                            .settingsButtonStyle()
                    }
                    
                    ShareLink(item: SettingsConstants.shareYouTubeURL) {
                        Label("Share App", systemImage: "square.and.arrow.up")
                            .settingsButtonStyle()
                    }
                
                    Button {
                        requestReview()
                    } label: {
                        Text("Rate App")
                            .settingsButtonStyle()
                    }

                    Text("Version \(SettingsConstants.appVersion)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                
                Spacer()
            }
            .padding(.horizontal)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Location access required", isPresented: $showLocationDeniedAlert) {
                Button("Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        openURL(url)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Please grant location access in Settings to use weather information.")
            }
        }
    }
}

extension View {
    func settingsButtonStyle() -> some View {
        font(.headline.bold())
            .foregroundStyle(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.blue.gradient)
            }
    }
}
