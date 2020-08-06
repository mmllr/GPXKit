import Foundation
import XCTest
@testable import GPXKit

let testXMLData = """
        <?xml version="1.0" encoding="UTF-8"?>
        <gpx creator="StravaGPX" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd http://www.garmin.com/xmlschemas/GpxExtensions/v3 http://www.garmin.com/xmlschemas/GpxExtensionsv3.xsd http://www.garmin.com/xmlschemas/TrackPointExtension/v1 http://www.garmin.com/xmlschemas/TrackPointExtensionv1.xsd" version="1.1" xmlns="http://www.topografix.com/GPX/1/1" xmlns:gpxtpx="http://www.garmin.com/xmlschemas/TrackPointExtension/v1" xmlns:gpxx="http://www.garmin.com/xmlschemas/GpxExtensions/v3">
            <metadata>
             <time>2020-03-18T12:39:47Z</time>
            </metadata>
            <trk>
                <name>Haus- und Seenrunde Ausdauer</name>
                <type>1</type>
                <trkseg>
                    <trkpt lat="51.2760600" lon="12.3769500">
                        <ele>114.2</ele>
                        <time>2020-03-18T12:39:47Z</time>
                        <extensions>
                            <power>42</power>
                            <gpxtpx:TrackPointExtension>
                                <gpxtpx:atemp>21</gpxtpx:atemp>
                                <gpxtpx:hr>97</gpxtpx:hr>
                                <gpxtpx:cad>40</gpxtpx:cad>
                            </gpxtpx:TrackPointExtension>
                        </extensions>
                    </trkpt>
                    <trkpt lat="51.2760420" lon="12.3769760">
                        <ele>114.0</ele>
                        <time>2020-03-18T12:39:48Z</time>
                        <extensions>
                            <power>272</power>
                            <gpxtpx:TrackPointExtension>
                                <gpxtpx:atemp>20</gpxtpx:atemp>
                                <gpxtpx:hr>97</gpxtpx:hr>
                                <gpxtpx:cad>40</gpxtpx:cad>
                            </gpxtpx:TrackPointExtension>
                        </extensions>
                    </trkpt>
                </trkseg>
            </trk>
        </gpx>
        """

let testTrack = GPXTrack(date: expectedDate(for: "2020-03-18T12:39:47Z"),
                         title: "Haus- und Seenrunde Ausdauer",
                         trackPoints: [
                            TrackPoint(coordinate: Coordinate(latitude: 51.2760600, longitude: 12.3769500, elevation: 114.2),
                                       date: expectedDate(for: "2020-03-18T12:39:47Z")),
                            TrackPoint(coordinate: Coordinate(latitude: 51.2760420, longitude: 12.3769760, elevation: 114.0),
                                       date: expectedDate(for: "2020-03-18T12:39:48Z"))
                         ])

let testTrackWithoutTime = GPXTrack(date: nil,
                         title: "Test track without time",
                         trackPoints: [
                            TrackPoint(coordinate: Coordinate(latitude: 51.2760600, longitude: 12.3769500, elevation: 114.2),
                                       date: nil),
                            TrackPoint(coordinate: Coordinate(latitude: 51.2760420, longitude: 12.3769760, elevation: 114.0),
                                       date: nil)
                         ])

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
        XCTAssertEqual(expected.trackPoints, actual.trackPoints, file: file, line: line)
    }
}

let testXMLWithoutExtensions = """
        <?xml version="1.0" encoding="UTF-8"?>
        <gpx creator="StravaGPX" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd http://www.garmin.com/xmlschemas/GpxExtensions/v3 http://www.garmin.com/xmlschemas/GpxExtensionsv3.xsd http://www.garmin.com/xmlschemas/TrackPointExtension/v1 http://www.garmin.com/xmlschemas/TrackPointExtensionv1.xsd" version="1.1" xmlns="http://www.topografix.com/GPX/1/1" xmlns:gpxtpx="http://www.garmin.com/xmlschemas/TrackPointExtension/v1" xmlns:gpxx="http://www.garmin.com/xmlschemas/GpxExtensions/v3">
            <metadata>
             <time>2020-03-18T12:39:47Z</time>
            </metadata>
            <trk>
                <name>Haus- und Seenrunde Ausdauer</name>
                <type>1</type>
                <trkseg>
                    <trkpt lat="51.2760600" lon="12.3769500">
                        <ele>114.2</ele>
                        <time>2020-03-18T12:39:47Z</time>
                    </trkpt>
                    <trkpt lat="51.2760420" lon="12.3769760">
                        <ele>114.0</ele>
                        <time>2020-03-18T12:39:48Z</time>
                    </trkpt>
                </trkseg>
            </trk>
        </gpx>
        """

let testXMLWithoutTime = """
        <?xml version="1.0" encoding="UTF-8"?>
        <gpx creator="StravaGPX" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd http://www.garmin.com/xmlschemas/GpxExtensions/v3 http://www.garmin.com/xmlschemas/GpxExtensionsv3.xsd http://www.garmin.com/xmlschemas/TrackPointExtension/v1 http://www.garmin.com/xmlschemas/TrackPointExtensionv1.xsd" version="1.1" xmlns="http://www.topografix.com/GPX/1/1" xmlns:gpxtpx="http://www.garmin.com/xmlschemas/TrackPointExtension/v1" xmlns:gpxx="http://www.garmin.com/xmlschemas/GpxExtensions/v3">
            <metadata>
            </metadata>
            <trk>
                <name>Haus- und Seenrunde Ausdauer</name>
                <type>1</type>
                <trkseg>
                    <trkpt lat="51.2760600" lon="12.3769500">
                        <ele>114.2</ele>
                    </trkpt>
                    <trkpt lat="51.2760420" lon="12.3769760">
                        <ele>114.0</ele>
                    </trkpt>
                </trkseg>
            </trk>
        </gpx>
        """
