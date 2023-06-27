import Foundation
import XCTest
import Difference

@testable import GPXKit
#if canImport(FoundationXML)
import FoundationXML
#endif

struct TestGPXPoint: Hashable, GeoCoordinate {
    var latitude: Double
    var longitude: Double
    var elevation: Double?

    @inlinable
    func with(_ block: (inout Self) throws -> Void) rethrows -> Self {
        var copy = self
        try block(&copy)
        return copy
    }
}

public func XCTAssertEqual<T: Equatable>(_ expected: @autoclosure () throws -> T, _ received: @autoclosure () throws -> T, file: StaticString = #filePath, line: UInt = #line) {
    do {
        let expected = try expected()
        let received = try received()
        XCTAssertTrue(expected == received, "Found difference for \n" + diff(expected, received).joined(separator: ", "), file: file, line: line)
    }
    catch {
        XCTFail("Caught error while testing: \(error)", file: file, line: line)
    }
}

fileprivate var iso8601Formatter: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = .withInternetDateTime
    return formatter
}()

fileprivate var importFormatter: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = .withInternetDateTime
    return formatter
}()

fileprivate var fractionalFormatter: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    if #available(macOS 10.13, iOS 12, watchOS 5, tvOS 11.0, *) {
        formatter.formatOptions = [.withFractionalSeconds, .withInternetDateTime]
    } else {
        formatter.formatOptions = .withInternetDateTime
    }
    return formatter
}()

func expectedDate(for dateString: String) -> Date {
    if let date = importFormatter.date(from: dateString) {
        return date
    } else {
        return fractionalFormatter.date(from: dateString)!
    }
}

func expectedString(for date: Date) -> String {
    return iso8601Formatter.string(from: date)
}

func givenTrackPoints(_ count: Int) -> [TrackPoint] {
    let date = Date()

    return (1..<count).map { sec in
        TrackPoint(coordinate: .random, date: date + TimeInterval(sec))
    }
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
        Coordinate(latitude: Double.random(in: -90..<90),
                   longitude: Double.random(in: -180..<180),
                   elevation: Double.random(in: 1..<100))
    }

    func offset(north: Double = 0, east: Double = 0, elevation: Double) -> Self {
        var offset = self.offset(north: north, east: east)
        offset.elevation = self.elevation + elevation
        return offset
    }

    func offset(distance: Double, grade: Double) -> Self {
        // elevation = grade * distance
        return offset(east: distance, elevation: distance * grade)
    }

    func offset(elevation: Double, grade: Double) -> Self {
        // distance = elevation / grade
        return offset(east: elevation / grade, elevation: elevation)
    }

    init(_ testPoint: TestGPXPoint) {
        self.init(latitude: testPoint.latitude, longitude: testPoint.longitude, elevation: testPoint.elevation ?? 0)
    }
}

extension TestGPXPoint {
    static var random: TestGPXPoint {
        TestGPXPoint(
            latitude: Double.random(in: -90..<90),
            longitude: Double.random(in: -180..<180),
            elevation: Bool.random() ? Double.random(in: 1..<100) : nil
        )
    }

    func offset(north: Double = 0, east: Double = 0) -> Self {
        // Earth’s radius, sphere
        let radius: Double = 6_378_137

        // Coordinate offsets in radians
        let dLat = north / radius
        let dLon = east / (radius * cos(.pi * latitude / 180))

        // OffsetPosition, decimal degrees
        return .init(
            latitude: latitude + dLat * 180 / .pi,
            longitude: longitude + dLon * 180 / .pi,
            elevation: elevation
        )
    }
}


extension TrackPoint {
    func expectedXMLNode(withDate: Bool = false) -> GPXKit.XMLNode {
        XMLNode(name: GPXTags.trackPoint.rawValue,
                attributes: [
                    GPXAttributes.latitude.rawValue: "\(coordinate.latitude)",
                    GPXAttributes.longitude.rawValue: "\(coordinate.longitude)"
                ],
                children: [
                    XMLNode(name: GPXTags.elevation.rawValue,
                            content: String(format:"%.2f", coordinate.elevation)),
                    withDate ? date.flatMap {
                        XMLNode(name: GPXTags.time.rawValue,
                                content: expectedString(for: $0) )
                    } : nil
                ].compactMap {$0 }
        )
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
        XCTAssertEqual(expected.description, actual.description, file: file, line: line)
        XCTAssertEqual(expected.keywords, actual.keywords, file: file, line: line)
        XCTAssertEqual(expected.trackPoints, actual.trackPoints, file: file, line: line)
        XCTAssertEqual(expected.graph, actual.graph, file: file, line: line)
        XCTAssertEqual(expected.bounds, actual.bounds, file: file, line: line)
    }

    /*
     public struct XMLNode: Equatable, Hashable {
     var name: String
     var attributes: [String: String] = [:]
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
        XCTAssertEqual(expected.attributes, actual.attributes, file: file, line: line)
        XCTAssertEqual(expected.children, actual.children, file: file, line: line)
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

func given(title: String = "track title", points: [TestGPXPoint]) -> String {
    let pointXML = points.map {
        let ele = $0.elevation.flatMap { "<ele>\($0)</ele>" } ?? ""
        return "<trkpt lat=\"\($0.latitude)\" lon=\"\($0.longitude)\">\(ele)</trkpt>"
    }.joined(separator: "\n")
    let xml =
    """
    <?xml version="1.0" encoding="UTF-8"?>
    <gpx creator="StravaGPX" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd http://www.garmin.com/xmlschemas/GpxExtensions/v3 http://www.garmin.com/xmlschemas/GpxExtensionsv3.xsd http://www.garmin.com/xmlschemas/TrackPointExtension/v1 http://www.garmin.com/xmlschemas/TrackPointExtensionv1.xsd" version="1.1" xmlns="http://www.topografix.com/GPX/1/1" xmlns:gpxtpx="http://www.garmin.com/xmlschemas/TrackPointExtension/v1" xmlns:gpxx="http://www.garmin.com/xmlschemas/GpxExtensions/v3">
        <metadata>
        </metadata>
        <trk>
            <name>\(title)</name>
            <type>1</type>
            <trkseg>
                \(pointXML)
            </trkseg>
        </trk>
    </gpx>
    """
    return xml
}


func expectedElevation(start: TestGPXPoint, end: TestGPXPoint, distanceFromStart: Double) -> Double? {
    guard let startElevation = start.elevation, let endElevation = end.elevation else { return nil }
    let deltaHeight = endElevation - startElevation
    return startElevation + deltaHeight * (distanceFromStart / start.distance(to: end))
}
