import Foundation
import XCTest
#if canImport(FoundationXML)
import FoundationXML
#endif
@testable import GPXKit

final class GPXExporterTests: XCTestCase {
    private var sut: GPXExporter!
    private var parseError: GPXParserError?
    private var iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = .withInternetDateTime
        return formatter
    }()
    private var result: GPXKit.XMLNode!
    private let expectedHeaderAttributes = [
        "creator": "GPXKit",
        "xmlns:xsi": "http://www.w3.org/2001/XMLSchema-instance",
        "xsi:schemaLocation": "http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd http://www.garmin.com/xmlschemas/GpxExtensions/v3 http://www.garmin.com/xmlschemas/GpxExtensionsv3.xsd http://www.garmin.com/xmlschemas/TrackPointExtension/v1 http://www.garmin.com/xmlschemas/TrackPointExtensionv1.xsd",
        "version": "1.1",
        "xmlns": "http://www.topografix.com/GPX/1/1",
        "xmlns:gpxtpx": "http://www.garmin.com/xmlschemas/TrackPointExtension/v1",
        "xmlns:gpxx": "http://www.garmin.com/xmlschemas/GpxExtensions/v3"
    ]

    private func parseResult(_ xmlString: String) {
        let xmlParser = BasicXMLParser(xml: xmlString)
        switch xmlParser.parse() {
        case let .success(rootNode):
            result = rootNode
        case let .failure(error):
            XCTFail(error.localizedDescription)
        }
    }

    func givenTrackPoints(_ count: Int) -> [TrackPoint] {
        let date = Date()

        return (1..<count).map { sec in
            TrackPoint(coordinate: .random, date: date + TimeInterval(sec))
        }
    }

    // MARK: Tests

    func testExportingAnEmptyTrackWithDateAndTitleResultsInAnEmptyGPXFile() {
        let date = Date()
        let track: GPXTrack = GPXTrack(date: date, title: "Track title", trackPoints: [])
        sut = GPXExporter(track: track)

        let expectedContent: GPXKit.XMLNode = XMLNode(
            name: GPXTags.gpx.rawValue,
            atttributes: expectedHeaderAttributes,
            children: [
                XMLNode(name: GPXTags.metadata.rawValue, children: [
                    XMLNode(name: GPXTags.time.rawValue, content: expectedString(for: date))
                ]),
                XMLNode(name: GPXTags.track.rawValue, children: [
                    XMLNode(name: GPXTags.name.rawValue, content: track.title)
                ])
            ])

        parseResult(sut.xmlString)

        assertNodesAreEqual(expectedContent, result)
    }

    func testExportingAnEmptyTrackWithoutDateResultsInAnEmptyGPXFileWithoutTitleAndDate() {
        let track: GPXTrack = GPXTrack(date: nil, title: "Track title", trackPoints: [])
        sut = GPXExporter(track: track)

        let expectedContent: GPXKit.XMLNode = XMLNode(
            name: GPXTags.gpx.rawValue,
            atttributes: expectedHeaderAttributes,
            children: [
                XMLNode(name: GPXTags.metadata.rawValue),
                XMLNode(name: GPXTags.track.rawValue, children: [
                    XMLNode(name: GPXTags.name.rawValue, content: track.title)
                ])
            ])

        parseResult(sut.xmlString)

        assertNodesAreEqual(expectedContent, result)
    }

    func testExportingANonEmptyTrack() {
        let date = Date()
        let track: GPXTrack = GPXTrack(
            date: date,
            title: "Track title",
            trackPoints: givenTrackPoints(10))
        sut = GPXExporter(track: track)

        parseResult(sut.xmlString)

        let expectedContent: GPXKit.XMLNode = XMLNode(
            name: GPXTags.gpx.rawValue,
            atttributes: expectedHeaderAttributes,
            children: [
                XMLNode(name: GPXTags.metadata.rawValue, children: [
                    XMLNode(name: GPXTags.time.rawValue, content: expectedString(for: date))
                ]),
                XMLNode(name: GPXTags.track.rawValue, children: [
                    XMLNode(name: GPXTags.name.rawValue, content: track.title),
                    XMLNode(name: GPXTags.trackSegment.rawValue,
                            children: track.trackPoints.map { $0.expectedXMLNode })
                ])
            ])

        parseResult(sut.xmlString)

        assertNodesAreEqual(expectedContent, result)
    }

    func testExportingACompleteTrack() {
        sut = GPXExporter(track: testTrackWithoutTime)

        let parser = GPXFileParser(xmlString: sut.xmlString)
        switch parser.parse() {
        case .success(let importedTrack):
            assertTracksAreEqual(testTrackWithoutTime, importedTrack)
        case .failure(let error):
            XCTFail(error.localizedDescription)
        }
    }

    func testItWillNotExportTheDatesFromTrack() {
        let track = GPXTrack(date: Date(),
                             title: "test track",
                             trackPoints: [
                                TrackPoint(coordinate: .random, date: Date()),
                                TrackPoint(coordinate: .random, date: Date()),
                                TrackPoint(coordinate: .random, date: Date()),
                                TrackPoint(coordinate: .random, date: Date()),
                             ])
        sut = GPXExporter(track: track, shouldExportDate: false)

        let expectedContent: GPXKit.XMLNode = XMLNode(
            name: GPXTags.gpx.rawValue,
            atttributes: expectedHeaderAttributes,
            children: [
                XMLNode(name: GPXTags.metadata.rawValue),
                XMLNode(name: GPXTags.track.rawValue, children: [
                    XMLNode(name: GPXTags.name.rawValue, content: track.title),
                    XMLNode(name: GPXTags.trackSegment.rawValue,
                            children: track.trackPoints.map { $0.expectedXMLNode })
                ])
            ])

        parseResult(sut.xmlString)

        assertNodesAreEqual(expectedContent, result)
    }
}
