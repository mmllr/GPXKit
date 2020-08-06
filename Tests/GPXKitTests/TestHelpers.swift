import Foundation
import XCTest
@testable import GPXKit

fileprivate var iso8601Formatter: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = .withInternetDateTime
    return formatter
}()

func expectedDate(for dateString: String) -> Date {
    return iso8601Formatter.date(from: dateString)!
}

func expectedString(for date: Date) -> String {
    return iso8601Formatter.string(from: date)
}

extension String {
    var strippedLines: String {
        split(separator: "\n")
            .map {
                $0.trimmingCharacters(in: .whitespaces)
            }.joined(separator: "\n")
    }
}

extension Coordinate {
    static var random: Coordinate {
        Coordinate(latitude: Double.random(in: 1..<100),
                   longitude: Double.random(in: 1..<100),
                   elevation: Double.random(in: 1..<100))
    }
}

extension TrackPoint {
    var expectedXMLNode: GPXKit.XMLNode {
        XMLNode(name: GPXTags.trackPoint.rawValue,
                atttributes: [
                    GPXAttributes.latitude.rawValue: "\(coordinate.latitude)",
                    GPXAttributes.longitude.rawValue: "\(coordinate.longitude)"
                ],
                children: [
                    XMLNode(name: GPXTags.elevation.rawValue,
                            content: String(format:"%.2f", coordinate.elevation))
                ])
    }
}
