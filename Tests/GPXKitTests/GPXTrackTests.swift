import Foundation
import XCTest
import GPXKit

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

    func testGradeSegments() {
        let start = Coordinate.leipzig.offset(elevation: 100)
        let first: Coordinate = start.offset(distance: 100, grade: 0.1)
        let second: Coordinate = first.offset(distance: 100, grade: 0.2)
        let third: Coordinate = second.offset(distance: 100, grade: -0.3)
        let fourth: Coordinate = third.offset(distance: 50, grade: 0.06)
        sut = GPXTrack(title: "Track", trackPoints: [
            start,
            first,
            second,
            third,
            fourth
        ].map { TrackPoint(coordinate: $0) }, elevationSmoothing: .segmentation(50))

        let expected: [GradeSegment] = [
            .init(start: 0, end: 100, grade: 0.1),
            .init(start: 100, end: 200, grade: 0.2),
            .init(start: 200, end: 300, grade: -0.3),
            .init(start: 300, end: sut.graph.distance, grade: 0.06)
        ]
        XCTAssertEqual(expected, sut.graph.gradeSegments)
    }
}
