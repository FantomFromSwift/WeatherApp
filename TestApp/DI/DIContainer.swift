import Foundation
import Observation
import SwiftData
import SwiftUI

@Observable
final class DIContainer {
    private static let getWeatherInfoKey = "getWeatherInfo"
    private static let darkModeKey = "darkMode"

    private var _getWeatherInfo: Bool
    var getWeatherInfo: Bool {
        get { _getWeatherInfo }
        set {
            _getWeatherInfo = newValue
            UserDefaults.standard.set(newValue, forKey: Self.getWeatherInfoKey)
        }
    }

    private var _darkMode: Bool
    var darkMode: Bool {
        get { _darkMode }
        set {
            _darkMode = newValue
            UserDefaults.standard.set(newValue, forKey: Self.darkModeKey)
        }
    }

    var isAppLoadingData: Bool = false

    let storageService: StorageServiceProtocol
    let networkService: NetworkServiceProtocol
    let locationService: LocationServiceProtocol
    let weatherService: WeatherServiceProtocol

    private(set) var getWeatherUC: GetWeatherUCProtocol

    init(modelContext: ModelContext) {
        self._getWeatherInfo = UserDefaults.standard.bool(forKey: Self.getWeatherInfoKey)
        self._darkMode = UserDefaults.standard.bool(forKey: Self.darkModeKey)
        self.storageService = StorageService(context: modelContext)
        self.networkService = NetworkService()
        self.networkService.startMonitoring()
        let locationService = LocationService()
        self.locationService = locationService
        self.weatherService = WeatherService()
        self.getWeatherUC = GetWeatherUC(
            networkService: networkService,
            locationService: locationService,
            weatherService: weatherService,
            storageService: storageService
        )
        locationService.setAuthorizationChangeHandler { [weak self] previousGranted, currentGranted in
            DispatchQueue.main.async {
                guard let self else { return }
                if !currentGranted {
                    self.getWeatherInfo = false
                } else if !previousGranted && currentGranted {
                    self.getWeatherInfo = true
                }
            }
        }
    }

    func makeListVM() -> ListVM {
        ListVM(
            storageService: storageService,
            appLoadingStateObserver: self
        )
    }

    func makeAddNoteVM(
        onSaveError: @escaping @Sendable (Error) -> Void,
        onSaveSuccess: @escaping @Sendable () -> Void
    ) -> AddNoteVM {
        AddNoteVM(
            getWeatherUC: getWeatherUC,
            weatherInclusionPolicy: self,
            appLoadingStateObserver: self,
            onSaveError: onSaveError,
            onSaveSuccess: onSaveSuccess
        )
    }

    func makeDetailVM(noteId: PersistentIdentifier) -> DetailVM {
        DetailVM(storageService: storageService, noteId: noteId)
    }
}

extension DIContainer: WeatherInclusionPolicyProtocol {
    var shouldIncludeWeather: Bool { getWeatherInfo }
}

extension DIContainer: AppLoadingStateObserverProtocol {
    func setAppLoading(_ loading: Bool) {
        isAppLoadingData = loading
    }
}
