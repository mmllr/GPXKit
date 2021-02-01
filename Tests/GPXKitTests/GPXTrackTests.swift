import Foundation
import XCTest
@testable import GPXKit

final class GPXTrackTests: XCTestCase {
    var sut: GPXTrack!

    override func setUpWithError() throws {
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    private func givenTrack(with coordinates: [Coordinate]) {
        sut = GPXTrack(
            title: "Track",
            trackPoints: coordinates.map { TrackPoint(coordinate: $0) }
        )
    }

    // MARK: - Tests -

    func testBoundingBoxForEmptyTrack() {
        givenTrack(with: [])

        XCTAssertEqual(.empty, sut.bounds)
    }

    func testBoundingBoxWithOnePointHasThePointAsBoundingBox() {
        let coord = Coordinate(latitude: 54, longitude: 12)
        givenTrack(with: [coord])

        let expected = GeoBounds(
            minLatitude: coord.latitude,
            minLongitude: coord.longitude,
            maxLatitude: coord.latitude,
            maxLongitude: coord.longitude
        )
        XCTAssertEqual(expected, sut.bounds)
    }

    func testBoundsHasTheMinimumAndMaximumCoordinates() {
        givenTrack(with: [
            Coordinate(latitude: -66, longitude: 33),
            Coordinate(latitude: -77, longitude: 45),
            Coordinate(latitude: 12, longitude: 120),
            Coordinate(latitude: 55, longitude: -33),
            Coordinate(latitude: 79, longitude: 33),
            Coordinate(latitude: -80, longitude: -177)
        ])

        let expected = GeoBounds(
            minLatitude: -80,
            minLongitude: -177,
            maxLatitude: 79,
            maxLongitude: 120
        )
        XCTAssertEqual(expected, sut.bounds)
    }
}
