import XCTest
import GPXKit
#if canImport(FoundationXML)
import FoundationXML
#endif

class GPXParserTests: XCTestCase {
    private var sut: GPXFileParser!
    private var parseError: GPXParserError?
    private var result: GPXTrack?

    private func parseXML(_ xml: String) {
        sut = GPXFileParser(xmlString: xml)
        switch sut.parse() {
        case .success(let track):
            result = track
        case .failure(let error):
            parseError = error
        }
    }

    // MARK: Tests

    func testImportingAnEmptyGPXString() {
        parseXML("")

        XCTAssertNil(result)
        if case let .parseError(error, line) = parseError {
            XCTAssertEqual(0, line)
            XCTAssertEqual(1, error.code)
        } else {
            XCTFail("Exepcted parse error, got \(String(describing: parseError))")
        }
    }

    func testParsingGPXFilesWithoutATrack() {
        parseXML("""
		<?xml version="1.0" encoding="UTF-8"?>
		<gpx creator="StravaGPX" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd http://www.garmin.com/xmlschemas/GpxExtensions/v3 http://www.garmin.com/xmlschemas/GpxExtensionsv3.xsd http://www.garmin.com/xmlschemas/TrackPointExtension/v1 http://www.garmin.com/xmlschemas/TrackPointExtensionv1.xsd" version="1.1" xmlns="http://www.topografix.com/GPX/1/1" xmlns:gpxtpx="http://www.garmin.com/xmlschemas/TrackPointExtension/v1" xmlns:gpxx="http://www.garmin.com/xmlschemas/GpxExtensions/v3">
			<metadata>
			 <time>2020-03-17T11:27:02Z</time>
			</metadata>
		</gpx>
		""")

        XCTAssertNil(result)
        XCTAssertEqual(.noTracksFound, parseError)
    }

    func testParsingTrackTitlesAndDescrption() {
        parseXML(
        """
		<?xml version="1.0" encoding="UTF-8"?>
		<gpx creator="StravaGPX" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd http://www.garmin.com/xmlschemas/GpxExtensions/v3 http://www.garmin.com/xmlschemas/GpxExtensionsv3.xsd http://www.garmin.com/xmlschemas/TrackPointExtension/v1 http://www.garmin.com/xmlschemas/TrackPointExtensionv1.xsd" version="1.1" xmlns="http://www.topografix.com/GPX/1/1" xmlns:gpxtpx="http://www.garmin.com/xmlschemas/TrackPointExtension/v1" xmlns:gpxx="http://www.garmin.com/xmlschemas/GpxExtensions/v3">
			<metadata>
			 <time>2020-03-17T11:27:02Z</time>
			</metadata>
			<trk>
				<name>Frühjahrsgeschlender ach wie schön!</name><desc>Track description</desc>
				<type>1</type>
			</trk>
		</gpx>
		"""
        )

        XCTAssertEqual("Frühjahrsgeschlender ach wie schön!", result?.title)
        XCTAssertEqual("Track description", result?.description)
    }

    func testParsingTrackSegmentsWithoutExtensions() {
        parseXML(testXMLWithoutExtensions)

        let expected = [
            TrackPoint(coordinate: Coordinate(latitude: 51.2760600, longitude: 12.3769500, elevation: 114.2),
                       date: expectedDate(for: "2020-07-03T13:20:50.000Z")),
            TrackPoint(coordinate: Coordinate(latitude: 51.2760420, longitude: 12.3769760, elevation: 114.0),
                       date: expectedDate(for: "2020-03-18T12:45:48Z"))
        ]

        assertTracksAreEqual(GPXTrack(date: expectedDate(for: "2020-03-18T12:39:47Z"),
                                title: "Haus- und Seenrunde Ausdauer",
                                trackPoints: expected), result!)
    }

    func testParsingTrackSegmentsWithExtensions() {
        parseXML(testXMLData)

        let expected = [
            TrackPoint(coordinate: Coordinate(latitude: 51.2760600, longitude: 12.3769500, elevation: 114.2),
                       date: expectedDate(for: "2020-03-18T12:39:47Z"),
                       power: Measurement<UnitPower>(value: 42, unit: .watts)),
            TrackPoint(coordinate: Coordinate(latitude: 51.2760420, longitude: 12.3769760, elevation: 114.0),
                       date: expectedDate(for: "2020-03-18T12:39:48Z"),
                       power: Measurement<UnitPower>(value: 272, unit: .watts))
        ]

        assertTracksAreEqual(GPXTrack(date: expectedDate(for: "2020-03-18T12:39:47Z"),
                                title: "Haus- und Seenrunde Ausdauer",
                description: "Track description",
                                trackPoints: expected), result!)
    }

    func testParsingTrackSegmentsWithoutTimeHaveANilDate() {
        parseXML("""
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
        """)

        let expected = [
            TrackPoint(coordinate: Coordinate(latitude: 51.2760600, longitude: 12.3769500, elevation: 114.2),
                       date: nil),
            TrackPoint(coordinate: Coordinate(latitude: 51.2760420, longitude: 12.3769760, elevation: 114.0),
                       date: nil)
        ]

        assertTracksAreEqual(GPXTrack(date: nil,
                                title: "Haus- und Seenrunde Ausdauer",
                                trackPoints: expected), result!)
    }

    func testParsingTrackWithoutElevation() {
        parseXML("""
        <?xml version="1.0" encoding="UTF-8"?>
        <gpx creator="StravaGPX" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd http://www.garmin.com/xmlschemas/GpxExtensions/v3 http://www.garmin.com/xmlschemas/GpxExtensionsv3.xsd http://www.garmin.com/xmlschemas/TrackPointExtension/v1 http://www.garmin.com/xmlschemas/TrackPointExtensionv1.xsd" version="1.1" xmlns="http://www.topografix.com/GPX/1/1" xmlns:gpxtpx="http://www.garmin.com/xmlschemas/TrackPointExtension/v1" xmlns:gpxx="http://www.garmin.com/xmlschemas/GpxExtensions/v3">
            <metadata>
            </metadata>
            <trk>
                <name>Haus- und Seenrunde Ausdauer</name>
                <type>1</type>
                <trkseg>
                    <trkpt lat="51.2760600" lon="12.3769500"></trkpt>
                    <trkpt lat="51.2760420" lon="12.3769760"></trkpt>
                </trkseg>
            </trk>
        </gpx>
        """)

        let expected = [
            TrackPoint(coordinate: Coordinate(latitude: 51.2760600, longitude: 12.3769500, elevation: 0),
                       date: nil),
            TrackPoint(coordinate: Coordinate(latitude: 51.2760420, longitude: 12.3769760, elevation: 0),
                       date: nil)
        ]

        assertTracksAreEqual(GPXTrack(date: nil,
                                      title: "Haus- und Seenrunde Ausdauer",
                                      trackPoints: expected), result!)

    }

    func testTrackLength() throws {
        parseXML(sampleGPX)

        let distance = try XCTUnwrap(result?.graph.distance)
        let elevation = try XCTUnwrap(result?.graph.elevationGain)

        XCTAssertEqual(3100.5625, distance, accuracy: 10)
        XCTAssertEqual(158.4000015258789, elevation, accuracy: 0.001)
    }

    func testTracksWithoutElevationInTheGPXHaveAnElevationOfZero() throws {
        parseXML(given(points: [.leipzig, .postPlatz, .dehner]))

        let elevation = try XCTUnwrap(result?.graph.elevationGain)
        XCTAssertEqual(0, elevation)
    }

    func testItInterpolatesElevationGapsWithElevationAtStartEndEndOfTheTrack() throws {
        // 0m: 100, 250m: nil, 500m: 120
        let start = TestGPXPoint.leipzig.with { $0.elevation = 100 }
        let points: [TestGPXPoint] = [
            start,
            start.offset(east: 250).with { $0.elevation = nil },
            start.offset(east: 400).with { $0.elevation = nil },
            start.offset(east: 450).with { $0.elevation = nil },
            start.offset(east: 500).with { $0.elevation = 120 },
            start.offset(east: 600).with { $0.elevation = nil },
            start.offset(east: 700).with { $0.elevation = nil },
            start.offset(east: 800).with { $0.elevation = 300 }
        ]
        parseXML(given(points: points))

        let expected: [Coordinate] = [
            Coordinate(points[0]),
            Coordinate(points[1].with { $0.elevation = expectedElevation(start: points[0], end: points[4], distanceFromStart: points[0].distance(to: points[1])) }),
            Coordinate(points[2].with { $0.elevation = expectedElevation(start: points[0], end: points[4], distanceFromStart: points[0].distance(to: points[2])) }),
            Coordinate(points[3].with { $0.elevation = expectedElevation(start: points[0], end: points[4], distanceFromStart: points[0].distance(to: points[3])) }),
            Coordinate(points[4]),
            Coordinate(points[5].with { $0.elevation = expectedElevation(start: points[4], end: points[7], distanceFromStart: points[4].distance(to: points[5])) }),
            Coordinate(points[6].with { $0.elevation = expectedElevation(start: points[4], end: points[7], distanceFromStart: points[4].distance(to: points[6])) }),
            Coordinate(points[7])
        ]

        let result = try XCTUnwrap(result).flatMap { $0.trackPoints.map { $0.coordinate } }
        XCTAssertEqual(expected, result)
    }

    func testItTakesTheFirstElevationWhenTheTrackStartsWithNoElevation() throws {
        let start = TestGPXPoint.leipzig.with { $0.elevation = nil }
        let points: [TestGPXPoint] = [
            start,
            start.offset(east: 250).with { $0.elevation = nil },
            start.offset(east: 400).with { $0.elevation = nil },
            start.offset(east: 500).with { $0.elevation = 120 }
        ]
        parseXML(given(points: points))

        let expected: [Coordinate] = [
            Coordinate(points[0].with { $0.elevation = 120 }),
            Coordinate(points[1].with { $0.elevation = 120 }),
            Coordinate(points[2].with { $0.elevation = 120 }),
            Coordinate(points[3])
        ]

        let result = try XCTUnwrap(result).flatMap { $0.trackPoints.map { $0.coordinate } }
        XCTAssertEqual(expected, result)
    }

    func testItTakesTheLastElevationWhenTheTrackEndsWithNoElevation() throws {
        let start = TestGPXPoint.leipzig.with { $0.elevation = 170 }
        let points: [TestGPXPoint] = [
            start,
            start.offset(east: 250).with { $0.elevation = nil },
            start.offset(east: 400),
            start.offset(east: 500).with { $0.elevation = nil }
        ]
        parseXML(given(points: points))

        let expected: [Coordinate] = [
            Coordinate(points[0]),
            Coordinate(points[1].with { $0.elevation = expectedElevation(start: points[0], end: points[2], distanceFromStart: points[0].distance(to: points[1])) }),
            Coordinate(points[2]),
            Coordinate(points[3].with { $0.elevation = 170 })
        ]

        let result = try XCTUnwrap(result).flatMap { $0.trackPoints.map { $0.coordinate } }
        XCTAssertEqual(expected, result)
    }

    func testEmptySegmentIsEmptyTrackPoints() throws {
        parseXML(given(points: []))

        let result = try XCTUnwrap(result)
        XCTAssertEqual([], result.trackPoints)
    }

    func testParsingKeywords() throws {
        parseXML("""
                 <?xml version="1.0" encoding="UTF-8"?>
                 <gpx creator="StravaGPX" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd http://www.garmin.com/xmlschemas/GpxExtensions/v3 http://www.garmin.com/xmlschemas/GpxExtensionsv3.xsd http://www.garmin.com/xmlschemas/TrackPointExtension/v1 http://www.garmin.com/xmlschemas/TrackPointExtensionv1.xsd" version="1.1" xmlns="http://www.topografix.com/GPX/1/1" xmlns:gpxtpx="http://www.garmin.com/xmlschemas/TrackPointExtension/v1" xmlns:gpxx="http://www.garmin.com/xmlschemas/GpxExtensions/v3">
                     <metadata>
                     <keywords>one    two three  \n  \t  four   </keywords>
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
                 """)

        let sut = try XCTUnwrap(self.result)
        XCTAssertEqual(["one", "two", "three", "four"], sut.keywords)
    }

    func testParsingAFileWithoutWaypointDefinitionsHasEmptyWaypoints() throws {
        parseXML(testXMLData)
        let sut = try XCTUnwrap(self.result)

        XCTAssertNil(sut.waypoints)
    }

    func testParsingWaypointAttributes() throws {
        parseXML(testXMLDataContainingWaypoint)
        let sut = try XCTUnwrap(self.result)

        let waypointStart = Waypoint(
            coordinate: Coordinate(latitude: 51.2760600, longitude: 12.3769500),
            date: expectedDate(for: "2020-03-18T12:39:47Z"),
            name: "Start",
            comment: "start comment",
            description: "This is the start"
        )

        let waypointFinish = Waypoint(
            coordinate: Coordinate(latitude: 51.2760420, longitude: 12.3769760),
            date: expectedDate(for: "2020-03-18T12:39:48Z"),
            name: "Finish",
            comment: "finish comment",
            description: "This is the finish"
        )

        XCTAssertEqual([waypointStart, waypointFinish], sut.waypoints)

    }
}
