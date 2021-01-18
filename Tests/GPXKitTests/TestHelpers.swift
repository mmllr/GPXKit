import Foundation
import XCTest
@testable import GPXKit
#if canImport(FoundationXML)
import FoundationXML
#endif

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

extension XCTest {
    func assertDatesEqual(
        _ expected: Date?,
        _ actual: Date?,
        granularity: Calendar.Component = .nanosecond,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard let lhs = expected, let rhs = actual else {
            XCTAssertEqual(expected, actual,
                           "Dates are not equal - expected: \(String(describing: expected)), actual: \(String(describing: actual))",
                           file: file,
                           line: line )
            return
        }
        XCTAssertTrue(
            Calendar.autoupdatingCurrent
                .isDate(lhs, equalTo: rhs, toGranularity: granularity),
            "Expected dates to be equal - expected: \(lhs), actual: \(rhs)", file: file, line: line
        )
    }

    func assertTracksAreEqual(
        _ expected: GPXTrack,
        _ actual: GPXTrack,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        assertDatesEqual(expected.date, actual.date, file: file, line: line)
        XCTAssertEqual(expected.title, actual.title, file: file, line: line)
        assertEqual(expected.trackPoints, actual.trackPoints, file: file, line: line)
    }

    /*
     public struct XMLNode: Equatable, Hashable {
     var name: String
     var atttributes: [String: String] = [:]
     var content: String = ""
     public var children: [XMLNode] = []
     }
     */
    func assertNodesAreEqual(
        _ expected: GPXKit.XMLNode,
        _ actual: GPXKit.XMLNode,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(expected.content, actual.content, file: file, line: line)
        XCTAssertEqual(expected.content, actual.content, file: file, line: line)
        XCTAssertEqual(expected.atttributes, actual.atttributes, file: file, line: line)
        assertEqual(expected.children, actual.children, file: file, line: line)
    }

    func assertEqual<T: BidirectionalCollection>(
        _ first: T,
        _ second: T,
        file: StaticString = #filePath,
        line: UInt = #line
    ) where T.Element: Hashable {
        let diff = second.difference(from: first).inferringMoves()
        let message = diff.asTestErrorMessage()

        XCTAssert(message.isEmpty, """
    The two collections are not equal. Differences:
    \(message)
    """, file: file, line: line)
    }

    func assertGeoCoordinateEqual(
        _ expected: GeoCoordinate,
        _ actual: GeoCoordinate,
        accuracy: Double = 0.0001,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(expected.latitude,
                       actual.latitude,
                       accuracy: accuracy,
                       "Expected latitude: \(expected.latitude), got \(actual.latitude)",
                       file: file, line: line)
        XCTAssertEqual(expected.longitude,
                       actual.longitude,
                       accuracy: accuracy,
                       "Expected longitude: \(expected.longitude), got \(actual.longitude)",
                       file: file,
                       line: line)
    }

    func assertGeoCoordinatesEqual<T: BidirectionalCollection>(
        _ expected: T,
        _ acutal: T,
        accuracy: Double = 0.00001,
        file: StaticString = #filePath,
        line: UInt = #line
    ) where T.Element: GeoCoordinate {
        XCTAssertEqual(expected.count, acutal.count)
        zip(expected, acutal).forEach { lhs, rhs in
            assertGeoCoordinateEqual(lhs, rhs, accuracy: accuracy, file: file, line: line)
        }
    }

}

private extension CollectionDifference {
    func asTestErrorMessage() -> String {
        let descriptions = compactMap(testDescription)

        guard !descriptions.isEmpty else {
            return ""
        }

        return "- " + descriptions.joined(separator: "\n- ")
    }

    func testDescription(for change: Change) -> String? {
        switch change {
        case .insert(let index, let element, let association):
            if let oldIndex = association {
                return """
                Element moved from index \(oldIndex) to \(index): \(element)
                """
            } else {
                return "Additional element at index \(index): \(element)"
            }
        case .remove(let index, let element, let association):
            // If a removal has an association, it means that
            // it's part of a move, which we're handling above.
            guard association == nil else {
                return nil
            }

            return "Missing element at index \(index): \(element)"
        }
    }
}
