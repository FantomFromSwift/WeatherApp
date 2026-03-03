import Observation
import SwiftUI

struct OnbPage: Equatable {
    var image: String
    var color: AnyGradient
    var title: String
}

@Observable
class OnboardingVM {
    private(set) var currentIndex: Int = 0
    private let pages: [OnbPage] = [
        OnbPage(
            image: "list.clipboard.fill",
            color: Color.blue.gradient,
            title: "Make your own notes any time! \nFix your memories."
        ),
        OnbPage(
            image: "sun.max.fill",
            color: Color.yellow.gradient,
            title: "Get current weather and save it \nwith your notes."
        ),
    ]

    var currentPage: OnbPage? {
        guard currentIndex >= 0, currentIndex < pages.count else { return nil }
        return pages[currentIndex]
    }

    var isLastPage: Bool {
        currentIndex >= pages.count - 1
    }

    func goToNextPage() -> Bool {
        guard currentIndex < pages.count - 1 else { return false }
        currentIndex += 1
        return true
    }
}
