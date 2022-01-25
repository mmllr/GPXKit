import Foundation

extension ISO8601DateFormatter {
    static var gpxKit: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        if #available(macOS 10.13, *) {
            formatter.formatOptions = .withFractionalSeconds
        } else {
            formatter.formatOptions = .withInternetDateTime
        }
        return formatter
    }()
}
