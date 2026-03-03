import Foundation

extension DateFormatter {
    static let gmt: Foundation.DateFormatter = {
        let formatter = Foundation.DateFormatter()
        formatter.timeZone = .gmt
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter
    }()
}
