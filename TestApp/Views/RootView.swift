import SwiftUI

struct RootView: View {
    enum Tab: Hashable {
        case home, settings
    }

    @Bindable var container: DIContainer
    @Bindable var listVM: ListVM
    @State private var selection: Tab = .home
    @State private var isAddNotePresented = false
    @State private var isActive: Bool = false
    var body: some View {
        TabView(selection: $selection){
            NavigationStack{
                ListView(vm: listVM, isAddNotePresented: $isAddNotePresented)
                    .onAppear {
                        container.locationService.requestWhenInUseAuthorization()
                    }
            }
            .tabItem {
                Label("Notes", systemImage: "list.bullet.rectangle.portrait")
                    .symbolEffect(.bounce, value: isActive)
                    .onTapGesture {
                        isActive.toggle()
                    }
            }
            .tag(Tab.home)
            
            SettingsView(container: container)
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                        .symbolEffect(.pulse, value: isActive)
                        .onTapGesture {
                            isActive.toggle()
                        }
                }
                .tag(Tab.settings)
        }
    }
}
