import Foundation
import XCTest
import GPXKit
import CustomDump

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

        XCTAssertNoDifference(.empty, sut.bounds)
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
        XCTAssertNoDifference(expected, sut.bounds)
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
        XCTAssertNoDifference(expected, sut.bounds)
    }

    func testGradeSegments() throws {
        let start = Coordinate.leipzig.offset(elevation: 100)
        let first: Coordinate = start.offset(distance: 100, grade: 0.1)
        let second: Coordinate = first.offset(distance: 100, grade: 0.2)
        let third: Coordinate = second.offset(distance: 100, grade: -0.3)
        let fourth: Coordinate = third.offset(distance: 50, grade: 0.06)
        sut = try GPXTrack(title: "Track", trackPoints: [
            start,
            first,
            second,
            third,
            fourth
        ].map { TrackPoint(coordinate: $0) }, elevationSmoothing: .segmentation(50))

        let expected: [GradeSegment] = try [
            XCTUnwrap(.init(start: 0, end: 100, elevationAtStart: 100, elevationAtEnd: 109.98)),
            XCTUnwrap(.init(start: 100, end: 200, elevationAtStart: 109.98, elevationAtEnd: 129.64)),
            XCTUnwrap(.init(start: 200, end: 300, elevationAtStart: 129.64, elevationAtEnd: 100.58)),
            XCTUnwrap(.init(start: 300, end: sut.graph.distance, elevationAtStart: 100.58, elevationAtEnd: 103.55))
        ]
        XCTAssertNoDifference(expected, sut.graph.gradeSegments)
    }

    func testGraphHasTheDistancesFromTheTrackPointsSpeed() {
        let start = Date.now
        let points: [TrackPoint] = [
            .init(coordinate: .dehner, date: start, speed: 1.mps),
            .init(coordinate: .dehner.offset(distance: 10, grade: 0), date: start.addingTimeInterval(1), speed: 1.mps),
            .init(coordinate: .dehner.offset(distance: 20, grade: 0), date: start.addingTimeInterval(2), speed: 1.mps),
            .init(coordinate: .dehner.offset(distance: 25, grade: 0), date: start.addingTimeInterval(3), speed: 1.mps),
            .init(coordinate: .dehner.offset(distance: 50, grade: 0), date: start.addingTimeInterval(4), speed: 1.mps),
        ]

        let sut = GPXTrack(title: "Track", trackPoints: points)

        XCTAssertNoDifference(4, sut.graph.distance)
        XCTAssertNoDifference([
            DistanceHeight(distance: 0, elevation: 0),
            DistanceHeight(distance: 1, elevation: 0),
            DistanceHeight(distance: 2, elevation: 0),
            DistanceHeight(distance: 3, elevation: 0),
            DistanceHeight(distance: 4, elevation: 0),
        ], sut.graph.heightMap)
        XCTAssertNoDifference([
            .init(coordinate: points[0].coordinate, distanceInMeters: 0),
            .init(coordinate: points[1].coordinate, distanceInMeters: 1),
            .init(coordinate: points[2].coordinate, distanceInMeters: 1),
            .init(coordinate: points[3].coordinate, distanceInMeters: 1),
            .init(coordinate: points[4].coordinate, distanceInMeters: 1),
        ], sut.graph.segments)
    }
}
