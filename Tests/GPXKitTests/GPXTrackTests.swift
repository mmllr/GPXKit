//
// GPXKit - MIT License - Copyright © 2024 Markus Müller. All rights reserved.
//

import CustomDump
import Foundation
import GPXKit
import Testing

struct GPXTrackTests {
    private func givenTrack(with coordinates: [Coordinate]) -> GPXTrack {
        GPXTrack(title: "Track", trackPoints: coordinates.map { TrackPoint(coordinate: $0) }, type: nil)
    }

    // MARK: - Tests -

    @Test
    func testBoundingBoxForEmptyTrack() {
        let sut = givenTrack(with: [])

        expectNoDifference(.empty, sut.bounds)
    }

    @Test
    func testBoundingBoxWithOnePointHasThePointAsBoundingBox() {
        let coord = Coordinate(latitude: 54, longitude: 12)
        let sut = givenTrack(with: [coord])

        let expected = GeoBounds(
            minLatitude: coord.latitude,
            minLongitude: coord.longitude,
            maxLatitude: coord.latitude,
            maxLongitude: coord.longitude
        )
        expectNoDifference(expected, sut.bounds)
    }

    @Test
    func testBoundsHasTheMinimumAndMaximumCoordinates() {
        let sut = givenTrack(with: [
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
        expectNoDifference(expected, sut.bounds)
    }

    @Test
    func testGradeSegments() throws {
        let start = Coordinate.leipzig.offset(elevation: 100)
        let first: Coordinate = start.offset(distance: 100, grade: 0.1)
        let second: Coordinate = first.offset(distance: 100, grade: 0.2)
        let third: Coordinate = second.offset(distance: 100, grade: -0.3)
        let fourth: Coordinate = third.offset(distance: 50, grade: 0.06)
        let sut = try GPXTrack(title: "Track", trackPoints: [
            start,
            first,
            second,
            third,
            fourth
        ].map { TrackPoint(coordinate: $0) }, elevationSmoothing: .segmentation(50), type: nil)

        let expected: [GradeSegment] = try [
            #require(.init(start: 0, end: 100, elevationAtStart: 100, elevationAtEnd: 109.98)),
            #require(.init(start: 100, end: 200, elevationAtStart: 109.98, elevationAtEnd: 129.64)),
            #require(.init(start: 200, end: 300, elevationAtStart: 129.64, elevationAtEnd: 100.58)),
            #require(.init(start: 300, end: sut.graph.distance, elevationAtStart: 100.58, elevationAtEnd: 103.55))
        ]
        expectNoDifference(expected, sut.graph.gradeSegments)
    }

    @Test
    func testGraphHasTheDistancesFromTheTrackPointsSpeed() {
        let start = Date()
        let points: [TrackPoint] = [
            .init(coordinate: .dehner, date: start, speed: 1.mps),
            .init(coordinate: .dehner.offset(distance: 10, grade: 0), date: start.addingTimeInterval(1), speed: 1.mps),
            .init(coordinate: .dehner.offset(distance: 20, grade: 0), date: start.addingTimeInterval(2), speed: 1.mps),
            .init(coordinate: .dehner.offset(distance: 25, grade: 0), date: start.addingTimeInterval(3), speed: 1.mps),
            .init(coordinate: .dehner.offset(distance: 50, grade: 0), date: start.addingTimeInterval(4), speed: 1.mps)
        ]

        let sut = GPXTrack(title: "Track", trackPoints: points, type: nil)

        expectNoDifference(4, sut.graph.distance)
        expectNoDifference([
            DistanceHeight(distance: 0, elevation: 0),
            DistanceHeight(distance: 1, elevation: 0),
            DistanceHeight(distance: 2, elevation: 0),
            DistanceHeight(distance: 3, elevation: 0),
            DistanceHeight(distance: 4, elevation: 0)
        ], sut.graph.heightMap)
        expectNoDifference([
            .init(coordinate: points[0].coordinate, distanceInMeters: 0),
            .init(coordinate: points[1].coordinate, distanceInMeters: 1),
            .init(coordinate: points[2].coordinate, distanceInMeters: 1),
            .init(coordinate: points[3].coordinate, distanceInMeters: 1),
            .init(coordinate: points[4].coordinate, distanceInMeters: 1)
        ], sut.graph.segments)
    }
}
