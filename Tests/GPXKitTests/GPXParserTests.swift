import CustomDump
import GPXKit
import XCTest
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
        case let .success(track):
            result = track
        case let .failure(error):
            parseError = error
        }
    }

    // MARK: Tests

    func testImportingAnEmptyGPXString() {
        parseXML("")

        XCTAssertNil(result)
        if case let .parseError(error, line) = parseError {
            XCTAssertNoDifference(0, line)
            XCTAssertNoDifference(1, error.code)
        } else {
            XCTFail("Exepcted parse error, got \(String(describing: parseError))")
        }
    }

    func testParsingGPXFilesWithoutATrack() throws {
        parseXML("""
        <?xml version="1.0" encoding="UTF-8"?>
        <gpx creator="StravaGPX" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd http://www.garmin.com/xmlschemas/GpxExtensions/v3 http://www.garmin.com/xmlschemas/GpxExtensionsv3.xsd http://www.garmin.com/xmlschemas/TrackPointExtension/v1 http://www.garmin.com/xmlschemas/TrackPointExtensionv1.xsd" version="1.1" xmlns="http://www.topografix.com/GPX/1/1" xmlns:gpxtpx="http://www.garmin.com/xmlschemas/TrackPointExtension/v1" xmlns:gpxx="http://www.garmin.com/xmlschemas/GpxExtensions/v3">
        	<metadata>
        	 <time>2020-03-17T11:27:02Z</time>
        	</metadata>
        </gpx>
        """)

        let sut = try XCTUnwrap(result)
        XCTAssertNoDifference("", sut.title)
        XCTAssertNoDifference(nil, sut.description)
        XCTAssertNoDifference(expectedDate(for: "2020-03-17T11:27:02Z"), sut.date)
        XCTAssertNoDifference([], sut.trackPoints)
        XCTAssertNoDifference([], sut.graph.heightMap)
        XCTAssertNoDifference([], sut.graph.segments)
        XCTAssertNoDifference([], sut.graph.climbs())
    }

    func testParsingTrackTitlesAndDescription() {
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

        XCTAssertNoDifference("Frühjahrsgeschlender ach wie schön!", result?.title)
        XCTAssertNoDifference("Track description", result?.description)
    }

    func testParsingTrackSegmentsWithoutExtensions() throws {
        parseXML(testXMLWithoutExtensions)

        let expected = [
            TrackPoint(
                coordinate: Coordinate(latitude: 51.2760600, longitude: 12.3769500, elevation: 114.2),
                date: expectedDate(for: "2020-07-03T13:20:50.000Z")
            ),
            TrackPoint(
                coordinate: Coordinate(latitude: 51.2760420, longitude: 12.3769760, elevation: 114.0),
                date: expectedDate(for: "2020-03-18T12:45:48Z")
            ),
        ]

        try assertTracksAreEqual(GPXTrack(
            date: expectedDate(for: "2020-03-18T12:39:47Z"),
            title: "Haus- und Seenrunde Ausdauer",
            trackPoints: expected
        ), XCTUnwrap(result))
    }

    func testParsingTrackSegmentsWithDefaultExtensions() throws {
        parseXML(testXMLData)

        let expected = [
            TrackPoint(
                coordinate: Coordinate(latitude: 51.2760600, longitude: 12.3769500, elevation: 114.2),
                date: expectedDate(for: "2020-03-18T12:39:47Z"),
                power: Measurement<UnitPower>(value: 42, unit: .watts),
                cadence: 40,
                heartrate: 97,
                temperature: Measurement<UnitTemperature>(value: 21, unit: .celsius)
            ),
            TrackPoint(
                coordinate: Coordinate(latitude: 51.2760420, longitude: 12.3769760, elevation: 114.0),
                date: expectedDate(for: "2020-03-18T12:39:48Z"),
                power: Measurement<UnitPower>(value: 272, unit: .watts),
                cadence: 45,
                heartrate: 87,
                temperature: Measurement<UnitTemperature>(value: 20.5, unit: .celsius)
            ),
        ]

        try assertTracksAreEqual(GPXTrack(
            date: expectedDate(for: "2020-03-18T12:39:47Z"),
            title: "Haus- und Seenrunde Ausdauer",
            description: "Track description",
            trackPoints: expected
        ), XCTUnwrap(result))
    }

    func testParsingTrackSegmentsWithNameSpacedExtensions() throws {
        parseXML(namespacedTestXMLData)

        let expected = [
            TrackPoint(
                coordinate: Coordinate(latitude: 51.2760600, longitude: 12.3769500, elevation: 114.2),
                date: expectedDate(for: "2020-03-18T12:39:47Z"),
                power: Measurement<UnitPower>(value: 166, unit: .watts),
                cadence: 99,
                heartrate: 90,
                temperature: Measurement<UnitTemperature>(value: 22, unit: .celsius)
            ),
            TrackPoint(
                coordinate: Coordinate(latitude: 51.2760420, longitude: 12.3769760, elevation: 114.0),
                date: expectedDate(for: "2020-03-18T12:39:48Z"),
                power: Measurement<UnitPower>(value: 230, unit: .watts),
                cadence: 101,
                heartrate: 92,
                temperature: Measurement<UnitTemperature>(value: 21, unit: .celsius)
            ),
        ]

        try assertTracksAreEqual(GPXTrack(
            date: expectedDate(for: "2020-03-18T12:39:47Z"),
            title: "Haus- und Seenrunde Ausdauer",
            description: "Track description",
            trackPoints: expected
        ), XCTUnwrap(result))
    }

    func testParsingTrackSegmentsWithoutTimeHaveANilDate() throws {
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
            TrackPoint(
                coordinate: Coordinate(latitude: 51.2760600, longitude: 12.3769500, elevation: 114.2),
                date: nil
            ),
            TrackPoint(
                coordinate: Coordinate(latitude: 51.2760420, longitude: 12.3769760, elevation: 114.0),
                date: nil
            ),
        ]

        try assertTracksAreEqual(GPXTrack(
            date: nil,
            title: "Haus- und Seenrunde Ausdauer",
            trackPoints: expected
        ), XCTUnwrap(result))
    }

    func testParsingTrackWithoutElevation() throws {
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
            TrackPoint(
                coordinate: Coordinate(latitude: 51.2760600, longitude: 12.3769500, elevation: 0),
                date: nil
            ),
            TrackPoint(
                coordinate: Coordinate(latitude: 51.2760420, longitude: 12.3769760, elevation: 0),
                date: nil
            ),
        ]

        try assertTracksAreEqual(GPXTrack(
            date: nil,
            title: "Haus- und Seenrunde Ausdauer",
            trackPoints: expected
        ), XCTUnwrap(result))
    }

    func testTrackPointsDateWithFraction() throws {
        parseXML(sampleGPX)

        let date = try XCTUnwrap(result?.trackPoints.first?.date)

        XCTAssertNoDifference(1_351_121_380, date.timeIntervalSince1970)
    }

    func testTrackLength() throws {
        parseXML(sampleGPX)

        let distance = try XCTUnwrap(result?.graph.distance)
        let elevation = try XCTUnwrap(result?.graph.elevationGain)

        XCTAssertEqual(3100.5625, distance, accuracy: 10)
        XCTAssertEqual(115.19, elevation, accuracy: 0.1)
    }

    func testTracksWithoutElevationInTheGPXHaveAnElevationOfZero() throws {
        parseXML(given(points: [.leipzig, .postPlatz, .dehner]))

        let elevation = try XCTUnwrap(result?.graph.elevationGain)
        XCTAssertNoDifference(0, elevation)
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
            start.offset(east: 800).with { $0.elevation = 300 },
        ]
        parseXML(given(points: points))

        let expected: [Coordinate] = [
            Coordinate(points[0]),
            Coordinate(points[1].with { $0.elevation = expectedElevation(
                start: points[0],
                end: points[4],
                distanceFromStart: points[0].distance(to: points[1])
            ) }),
            Coordinate(points[2].with { $0.elevation = expectedElevation(
                start: points[0],
                end: points[4],
                distanceFromStart: points[0].distance(to: points[2])
            ) }),
            Coordinate(points[3].with { $0.elevation = expectedElevation(
                start: points[0],
                end: points[4],
                distanceFromStart: points[0].distance(to: points[3])
            ) }),
            Coordinate(points[4]),
            Coordinate(points[5].with { $0.elevation = expectedElevation(
                start: points[4],
                end: points[7],
                distanceFromStart: points[4].distance(to: points[5])
            ) }),
            Coordinate(points[6].with { $0.elevation = expectedElevation(
                start: points[4],
                end: points[7],
                distanceFromStart: points[4].distance(to: points[6])
            ) }),
            Coordinate(points[7]),
        ]

        let result = try XCTUnwrap(result).flatMap { $0.trackPoints.map(\.coordinate) }
        XCTAssertNoDifference(expected, result)
    }

    func testItTakesTheFirstElevationWhenTheTrackStartsWithNoElevation() throws {
        let start = TestGPXPoint.leipzig.with { $0.elevation = nil }
        let points: [TestGPXPoint] = [
            start,
            start.offset(east: 250).with { $0.elevation = nil },
            start.offset(east: 400).with { $0.elevation = nil },
            start.offset(east: 500).with { $0.elevation = 120 },
        ]
        parseXML(given(points: points))

        let expected: [Coordinate] = [
            Coordinate(points[0].with { $0.elevation = 120 }),
            Coordinate(points[1].with { $0.elevation = 120 }),
            Coordinate(points[2].with { $0.elevation = 120 }),
            Coordinate(points[3]),
        ]

        let result = try XCTUnwrap(result).flatMap { $0.trackPoints.map(\.coordinate) }
        XCTAssertNoDifference(expected, result)
    }

    func testItTakesTheLastElevationWhenTheTrackEndsWithNoElevation() throws {
        let start = TestGPXPoint.leipzig.with { $0.elevation = 170 }
        let points: [TestGPXPoint] = [
            start,
            start.offset(east: 250).with { $0.elevation = nil },
            start.offset(east: 400),
            start.offset(east: 500).with { $0.elevation = nil },
        ]
        parseXML(given(points: points))

        let expected: [Coordinate] = [
            Coordinate(points[0]),
            Coordinate(points[1].with { $0.elevation = expectedElevation(
                start: points[0],
                end: points[2],
                distanceFromStart: points[0].distance(to: points[1])
            ) }),
            Coordinate(points[2]),
            Coordinate(points[3].with { $0.elevation = 170 }),
        ]

        let result = try XCTUnwrap(result).flatMap { $0.trackPoints.map(\.coordinate) }
        XCTAssertNoDifference(expected, result)
    }

    func testEmptySegmentIsEmptyTrackPoints() throws {
        parseXML(given(points: []))

        let result = try XCTUnwrap(result)
        XCTAssertNoDifference([], result.trackPoints)
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
        XCTAssertNoDifference(["one", "two", "three", "four"], sut.keywords)
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

        XCTAssertNoDifference([waypointStart, waypointFinish], sut.waypoints)
    }

    func testParsingRouteFiles() throws {
        parseXML("""
        <?xml version="1.0" encoding="UTF-8"?>
        <gpx creator="StravaGPX" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd http://www.garmin.com/xmlschemas/GpxExtensions/v3 http://www.garmin.com/xmlschemas/GpxExtensionsv3.xsd http://www.garmin.com/xmlschemas/TrackPointExtension/v1 http://www.garmin.com/xmlschemas/TrackPointExtensionv1.xsd" version="1.1" xmlns="http://www.topografix.com/GPX/1/1" xmlns:gpxtpx="http://www.garmin.com/xmlschemas/TrackPointExtension/v1" xmlns:gpxx="http://www.garmin.com/xmlschemas/GpxExtensions/v3">
            <rte>
                <name>Haus- und Seenrunde Ausdauer</name>
                <rtept lat="51.2760600" lon="12.3769500">
                  <ele>114.2</ele>
                </rtept>
                <rtept lat="51.2760420" lon="12.3769760">
                  <ele>114.0</ele>
                </rtept>
            </rte>
        </gpx>
        """)

        let expected = [
            TrackPoint(
                coordinate: Coordinate(latitude: 51.2760600, longitude: 12.3769500, elevation: 114.2),
                date: nil
            ),
            TrackPoint(
                coordinate: Coordinate(latitude: 51.2760420, longitude: 12.3769760, elevation: 114),
                date: nil
            ),
        ]

        try assertTracksAreEqual(GPXTrack(
            date: nil,
            title: "Haus- und Seenrunde Ausdauer",
            trackPoints: expected
        ), XCTUnwrap(result))
    }

    func testParsingTrackWithoutNameHaveAnEmptyName() throws {
        parseXML("""
        <?xml version="1.0" encoding="UTF-8"?>
        <gpx creator="StravaGPX" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd http://www.garmin.com/xmlschemas/GpxExtensions/v3 http://www.garmin.com/xmlschemas/GpxExtensionsv3.xsd http://www.garmin.com/xmlschemas/TrackPointExtension/v1 http://www.garmin.com/xmlschemas/TrackPointExtensionv1.xsd" version="1.1" xmlns="http://www.topografix.com/GPX/1/1" xmlns:gpxtpx="http://www.garmin.com/xmlschemas/TrackPointExtension/v1" xmlns:gpxx="http://www.garmin.com/xmlschemas/GpxExtensions/v3">
            <metadata>
            </metadata>
            <trk>
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
            TrackPoint(
                coordinate: Coordinate(latitude: 51.2760600, longitude: 12.3769500, elevation: 114.2),
                date: nil
            ),
            TrackPoint(
                coordinate: Coordinate(latitude: 51.2760420, longitude: 12.3769760, elevation: 114.0),
                date: nil
            ),
        ]

        try assertTracksAreEqual(
            GPXTrack(
                date: nil,
                title: "",
                trackPoints: expected
            ),
            XCTUnwrap(result)
        )
    }

    func testParsingWaypointWithEmptyTrack() throws {
        let input = """
        <?xml version="1.0" encoding="UTF-8"?>
        <gpx xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://www.topografix.com/GPX/1/1" xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd http://www.garmin.com/xmlschemas/GpxExtensions/v3 http://www.garmin.com/xmlschemas/GpxExtensionsv3.xsd http://www.garmin.com/xmlschemas/TrackPointExtension/v1 http://www.garmin.com/xmlschemas/TrackPointExtensionv1.xsd http://www.topografix.com/GPX/gpx_style/0/2 http://www.topografix.com/GPX/gpx_style/0/2/gpx_style.xsd" xmlns:gpxtpx="http://www.garmin.com/xmlschemas/TrackPointExtension/v1" xmlns:gpxx="http://www.garmin.com/xmlschemas/GpxExtensions/v3" xmlns:gpx_style="http://www.topografix.com/GPX/gpx_style/0/2" version="1.1" creator="gpxgenerator.com">
        <metadata>
            <name>gpxgenerator_path</name>
            <author>
                <name>gpx.studio</name>
                <link href="https://gpx.studio"></link>
            </author>
        </metadata>
        <trk></trk>
        <wpt lat="53.060632820504345" lon="5.6932974383264616">
            <ele>8.4</ele>
            <sym> </sym>
        </wpt>

        <wpt lat="53.06485377614443" lon="5.702670398232679">
            <ele>8.3</ele>
            <sym> </sym>
        </wpt>
        </gpx>
        """

        let sut = GPXFileParser(xmlString: input)

        let track = try sut.parse().get()
        XCTAssertNoDifference([], track.trackPoints)
        XCTAssertNoDifference([], track.graph.heightMap)
        XCTAssertNoDifference([], track.graph.segments)
        XCTAssertNoDifference(.zero, track.graph.distance)
        XCTAssertNoDifference(.zero, track.graph.elevationGain)
        XCTAssertNoDifference([
            Waypoint(coordinate: .init(latitude: 53.060632820504345, longitude: 5.6932974383264616, elevation: 8.4)),
            Waypoint(coordinate: .init(latitude: 53.06485377614443, longitude: 5.702670398232679, elevation: 8.3)),
        ], track.waypoints)
    }

    func testParsingWaypointWithoutTrack() throws {
        let input = """
        <?xml version="1.0" encoding="UTF-8"?>
        <gpx xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://www.topografix.com/GPX/1/1" xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd http://www.garmin.com/xmlschemas/GpxExtensions/v3 http://www.garmin.com/xmlschemas/GpxExtensionsv3.xsd http://www.garmin.com/xmlschemas/TrackPointExtension/v1 http://www.garmin.com/xmlschemas/TrackPointExtensionv1.xsd http://www.topografix.com/GPX/gpx_style/0/2 http://www.topografix.com/GPX/gpx_style/0/2/gpx_style.xsd" xmlns:gpxtpx="http://www.garmin.com/xmlschemas/TrackPointExtension/v1" xmlns:gpxx="http://www.garmin.com/xmlschemas/GpxExtensions/v3" xmlns:gpx_style="http://www.topografix.com/GPX/gpx_style/0/2" version="1.1" creator="gpxgenerator.com">
        <metadata>
            <name>gpxgenerator_path</name>
            <author>
                <name>gpx.studio</name>
                <link href="https://gpx.studio"></link>
            </author>
        </metadata>
        <wpt lat="53.060632820504345" lon="5.6932974383264616">
            <ele>8.4</ele>
            <sym> </sym>
        </wpt>

        <wpt lat="53.06485377614443" lon="5.702670398232679">
            <ele>8.3</ele>
            <sym> </sym>
        </wpt>
        </gpx>
        """

        let sut = GPXFileParser(xmlString: input)

        let track = try sut.parse().get()
        XCTAssertNoDifference([], track.trackPoints)
        XCTAssertNoDifference([], track.graph.heightMap)
        XCTAssertNoDifference([], track.graph.segments)
        XCTAssertNoDifference(.zero, track.graph.distance)
        XCTAssertNoDifference(.zero, track.graph.elevationGain)
        XCTAssertNoDifference([
            Waypoint(coordinate: .init(latitude: 53.060632820504345, longitude: 5.6932974383264616, elevation: 8.4)),
            Waypoint(coordinate: .init(latitude: 53.06485377614443, longitude: 5.702670398232679, elevation: 8.3)),
        ], track.waypoints)
    }

    func testParsingTrackWithMultipleSegments() throws {
        parseXML("""
        <?xml version="1.0" encoding="UTF-8"?>
        <gpx creator="StravaGPX"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd http://www.garmin.com/xmlschemas/GpxExtensions/v3 http://www.garmin.com/xmlschemas/GpxExtensionsv3.xsd http://www.garmin.com/xmlschemas/TrackPointExtension/v1 http://www.garmin.com/xmlschemas/TrackPointExtensionv1.xsd" version="1.1"
        xmlns="http://www.topografix.com/GPX/1/1"
        xmlns:gpxtpx="http://www.garmin.com/xmlschemas/TrackPointExtension/v1"
        xmlns:gpxx="http://www.garmin.com/xmlschemas/GpxExtensions/v3">
        <metadata>
        </metadata>
        <trk>
        <type>1</type>
        <trkseg>
            <trkpt lat="53.0736462" lon="13.1756965">
                <ele>51.71003342</ele>
                <time>2023-05-20T08:20:07Z</time>
            </trkpt>
            <trkpt lat="53.0736242" lon="13.1757405">
                <ele>51.7000351</ele>
                <time>2023-05-20T08:20:08Z</time>
            </trkpt>
            <trkpt lat="53.0735992" lon="13.1757855">
                <ele>51.7000351</ele>
                <time>2023-05-20T08:20:09Z</time>
            </trkpt>
            <trkpt lat="53.0735793" lon="13.1758284">
                <ele>51.67003632</ele>
                <time>2023-05-20T08:20:10Z</time>
            </trkpt>
            <trkpt lat="53.0735543" lon="13.1758994">
                <ele>51.66003799</ele>
                <time>2023-05-20T08:20:11Z</time>
            </trkpt>
        </trkseg>
        <trkseg>
            <trkpt lat="53.186896" lon="13.132096">
                <ele>54.38999939</ele>
                <time>2023-05-20T10:35:19Z</time>
            </trkpt>
            <trkpt lat="53.186909" lon="13.132093">
                <ele>54.34999847</ele>
                <time>2023-05-20T10:35:20Z</time>
            </trkpt>
            <trkpt lat="53.1869289" lon="13.1320901">
                <ele>54.22999954</ele>
                <time>2023-05-20T10:35:21Z</time>
            </trkpt>
            <trkpt lat="53.1869399" lon="13.1320881">
                <ele>54.16999817</ele>
                <time>2023-05-20T10:35:22Z</time>
            </trkpt>
            <trkpt lat="53.1869479" lon="13.1320822">
                <ele>54.13999939</ele>
                <time>2023-05-20T10:35:23Z</time>
            </trkpt>
        </trkseg>
        </trk>
        </gpx>
        """)

        let expected = [
            TrackPoint(
                coordinate: Coordinate(latitude: 53.0736462, longitude: 13.1756965, elevation: 51.71003342),
                date: expectedDate(for: "2023-05-20T08:20:07Z")
            ),
            TrackPoint(
                coordinate: Coordinate(latitude: 53.0736242, longitude: 13.1757405, elevation: 51.7000351),
                date: expectedDate(for: "2023-05-20T08:20:08Z")
            ),
            TrackPoint(
                coordinate: Coordinate(latitude: 53.0735992, longitude: 13.1757855, elevation: 51.7000351),
                date: expectedDate(for: "2023-05-20T08:20:09Z")
            ),
            TrackPoint(
                coordinate: Coordinate(latitude: 53.0735793, longitude: 13.1758284, elevation: 51.67003632),
                date: expectedDate(for: "2023-05-20T08:20:10Z")
            ),
            TrackPoint(
                coordinate: Coordinate(latitude: 53.0735543, longitude: 13.1758994, elevation: 51.66003799),
                date: expectedDate(for: "2023-05-20T08:20:11Z")
            ),
            // 2nd segment
            TrackPoint(
                coordinate: Coordinate(latitude: 53.186896, longitude: 13.132096, elevation: 54.38999939),
                date: expectedDate(for: "2023-05-20T10:35:19Z")
            ),
            TrackPoint(
                coordinate: Coordinate(latitude: 53.186909, longitude: 13.132093, elevation: 54.34999847),
                date: expectedDate(for: "2023-05-20T10:35:20Z")
            ),
            TrackPoint(
                coordinate: Coordinate(latitude: 53.1869289, longitude: 13.1320901, elevation: 54.22999954),
                date: expectedDate(for: "2023-05-20T10:35:21Z")
            ),
            TrackPoint(
                coordinate: Coordinate(latitude: 53.1869399, longitude: 13.1320881, elevation: 54.16999817),
                date: expectedDate(for: "2023-05-20T10:35:22Z")
            ),
            TrackPoint(
                coordinate: Coordinate(latitude: 53.1869479, longitude: 13.1320822, elevation: 54.13999939),
                date: expectedDate(for: "2023-05-20T10:35:23Z")
            ),
        ]

        try assertTracksAreEqual(
            GPXTrack(
                date: nil,
                title: "",
                trackPoints: expected,
                segments: [
                    .init(
                        range: 0..<5, distance: expected[0..<5].expectedDistance()
                        ),
                    .init(
                        range: 5..<10, distance: expected[5..<10].expectedDistance()
                    )
                ]
            ),
            XCTUnwrap(result)
        )
    }
}
