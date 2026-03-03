import SwiftData
import SwiftUI

enum AppFlow: Hashable {
    case splash
    case onboarding
    case main
}

@main
struct TestAppApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Note.self,
            WeatherDataModel.self,
        ])
        if let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            try? FileManager.default.createDirectory(at: appSupport, withIntermediateDirectories: true)
        }
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        do {
            return try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    init() {
        _container = State(
            initialValue: DIContainer(
                modelContext: sharedModelContainer.mainContext
            )
        )
    }

    @State private var container: DIContainer
    @State private var flow: AppFlow = .splash
    @State private var listVM: ListVM?
    @AppStorage("isSeenOnb") private var isOnboardingSeen = false

    var body: some Scene {
        WindowGroup {
            Group {
                switch flow {
                case .splash:
                    AppSplashView(
                        container: container,
                        listVM: $listVM,
                        flow: $flow,
                        isOnboardingSeen: isOnboardingSeen
                    )
                case .onboarding:
                    Onboarding(onComplete: {
                        isOnboardingSeen = true
                        flow = .main
                    })
                case .main:
                    if let listVM {
                        ZStack {
                            RootView(container: container, listVM: listVM)
                            if container.isAppLoadingData {
                                Splash(container: container)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background(.regularMaterial)
                                    .ignoresSafeArea()
                            }
                        }
                    }
                }
            }
            .environment(container)
            .preferredColorScheme(
                container.darkMode ? ColorScheme.dark : ColorScheme.light
            )
        }
        .modelContainer(sharedModelContainer)
    }
}
