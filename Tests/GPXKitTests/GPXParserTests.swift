import XCTest
@testable import GPXKit
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

    func testParsingTrackTitles() {
        parseXML("""
		<?xml version="1.0" encoding="UTF-8"?>
		<gpx creator="StravaGPX" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd http://www.garmin.com/xmlschemas/GpxExtensions/v3 http://www.garmin.com/xmlschemas/GpxExtensionsv3.xsd http://www.garmin.com/xmlschemas/TrackPointExtension/v1 http://www.garmin.com/xmlschemas/TrackPointExtensionv1.xsd" version="1.1" xmlns="http://www.topografix.com/GPX/1/1" xmlns:gpxtpx="http://www.garmin.com/xmlschemas/TrackPointExtension/v1" xmlns:gpxx="http://www.garmin.com/xmlschemas/GpxExtensions/v3">
			<metadata>
			 <time>2020-03-17T11:27:02Z</time>
			</metadata>
			<trk>
				<name>Frühjahrsgeschlender ach wie schön!</name>
				<type>1</type>
			</trk>
		</gpx>
		""")

        XCTAssertEqual("Frühjahrsgeschlender ach wie schön!", result?.title)
    }

    func testParsingTrackSegmentsWithoutExtensions() {
        parseXML(testXMLWithoutExtensions)

        let expected = [
            TrackPoint(coordinate: Coordinate(latitude: 51.2760600, longitude: 12.3769500, elevation: 114.2),
                       date: expectedDate(for: "2020-03-18T12:39:47Z")),
            TrackPoint(coordinate: Coordinate(latitude: 51.2760420, longitude: 12.3769760, elevation: 114.0),
                       date: expectedDate(for: "2020-03-18T12:39:48Z"))
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

    func testTrackLength() throws {
        parseXML(sampleGPX)

        let distance = try XCTUnwrap(result?.graph.distance)
        let elevation = try XCTUnwrap(result?.graph.elevationGain)

        XCTAssertEqual(3100.5625, distance, accuracy: 10)
        XCTAssertEqual(158.4000015258789, elevation, accuracy: 0.001)
    }
}
