import SwiftUI

struct Onboarding: View {
    @State private var vm = OnboardingVM()
    @State private var displayedColor: AnyGradient = Color.primary.gradient
    private static let symbolEffectDuration: Double = 0.25
    var onComplete: () -> Void

    private var currentPage: OnbPage? {
        vm.currentPage
    }

    var body: some View {
        VStack {
            if let page = currentPage {
                Spacer()
                Image(systemName: page.image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: adaptyW(150), height: adaptyH(150))
                    .foregroundStyle(displayedColor)
                    .contentTransition(.symbolEffect(.replace))
                    .onAppear {
                        displayedColor = page.color
                    }
                    .onChange(of: vm.currentIndex) { _, _ in
                        Task { @MainActor in
                            try? await Task.sleep(for: .seconds(Self.symbolEffectDuration))
                            if let page = currentPage {
                                displayedColor = page.color
                            }
                        }
                    }
                Spacer()
                VStack{
                    VStack (spacing: 16){
                        Text(page.title)
                            .font(.title3)
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.center)
                            .contentTransition(.symbolEffect(.replace))
                        Button {
                            if vm.goToNextPage() {
                                
                            } else {
                                onComplete()
                            }
                        } label: {
                            Text("Next")
                                .font(.headline.bold())
                                .foregroundStyle(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background {
                                    RoundedRectangle(cornerRadius: 36)
                                        .fill(.blue.gradient)
                                        .padding(.horizontal)
                                }
                        }
                        .sensoryFeedback(.impact(flexibility: .soft), trigger: currentPage)
                    }
                    .padding()
                }
            }
        }
    }
}

#Preview {
    Onboarding(onComplete: {})
}

