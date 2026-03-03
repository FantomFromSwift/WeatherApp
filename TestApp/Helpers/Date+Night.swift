import Foundation

extension Date {
    var isNightByCreationTime: Bool {
        let hour = Calendar.current.component(.hour, from: self)
        return hour >= 22 || hour < 6
    }
}
