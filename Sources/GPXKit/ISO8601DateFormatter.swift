//
// GPXKit - MIT License - Copyright © 2024 Markus Müller. All rights reserved.
//

import Foundation

extension ISO8601DateFormatter {
    nonisolated(unsafe) static var importing: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = .withInternetDateTime
        return formatter
    }()

    nonisolated(unsafe) static var importingFractionalSeconds: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        if #available(macOS 10.13, iOS 12, tvOS 11.0, *) {
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        } else {
            formatter.formatOptions = .withInternetDateTime
        }
        return formatter
    }()

    nonisolated(unsafe) static var exporting: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = .withInternetDateTime
        return formatter
    }()
}
