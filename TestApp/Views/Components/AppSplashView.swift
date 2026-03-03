import SwiftUI

struct AppSplashView: View {
    @Bindable var container: DIContainer
    @Binding var listVM: ListVM?
    @Binding var flow: AppFlow
    var isOnboardingSeen: Bool

    private static let minSplashDuration: TimeInterval = 3.0

    var body: some View {
        Splash(container: container)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .task { @MainActor in
                guard listVM == nil else { return }
                let vm = container.makeListVM()
                listVM = vm
                await vm.performInitialLoad(minDuration: Self.minSplashDuration)
                flow = isOnboardingSeen ? .main : .onboarding
            }
    }
}
