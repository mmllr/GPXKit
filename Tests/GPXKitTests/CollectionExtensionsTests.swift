import CustomDump
import Foundation
import GPXKit
import XCTest

final class ArrayExtensionsTests: XCTestCase {
    func testRemovingNearbyCoordinatesInEmptyCollection() {
        let coords: [Coordinate] = []

        XCTAssertNoDifference([], coords.removeIf(closerThan: 1))
    }

    func testRemovingNearbyCoordinatesWithOneElement() {
        let coords: [Coordinate] = [.leipzig]

        XCTAssertNoDifference([.leipzig], coords.removeIf(closerThan: 1))
    }

    func testRemovingNearbyCoordinatesWithtwoElement() {
        let coords: [Coordinate] = [.leipzig, .dehner]

        XCTAssertNoDifference([.leipzig, .dehner], coords.removeIf(closerThan: 1))
    }

    func testRemovingDuplicateCoordinates() {
        let start = Coordinate.leipzig
        let coords: [Coordinate] = [
            start,
            start.offset(east: 60),
            start.offset(east: 100),
            start.offset(north: 120),
            start.offset(north: 160),
            .postPlatz,
        ]

        let result = coords.removeIf(closerThan: 50)
        XCTAssertNoDifference([coords[0], coords[1], coords[3], .postPlatz], result)
    }

    func testSmoothingElevation() {
        let start = Coordinate.leipzig.offset(elevation: 200)
        let coords: [Coordinate] = stride(from: 0, to: 100, by: 1).map { idx in
            start.offset(
                north: Double.random(in: 100 ... 1000),
                east: Double.random(in: 100 ... 1000),
                elevation: Double.random(in: idx.isMultiple(of: 10) ? 500 ... 550 : 100 ... 110)
            )
        }

        let avg = coords.map(\.elevation).reduce(0, +) / Double(coords.count)

        for (idx, coord) in coords.smoothedElevation(sampleCount: 50).enumerated() {
            assertGeoCoordinateEqual(coord, coords[idx])
            XCTAssertEqual(avg, coord.elevation, accuracy: 15)
        }
    }

    func testFlatteningGradeSegments() throws {
        let grades: [GradeSegment] = try [
            XCTUnwrap(.init(start: 0, end: 100, elevationAtStart: 50, elevationAtEnd: 60)),
            XCTUnwrap(.init(start: 100, end: 200, elevationAtStart: 60, elevationAtEnd: 75)),
            XCTUnwrap(GradeSegment(start: 200, end: 270, elevationAtStart: 75, elevationAtEnd: 82)),
        ]

        XCTAssertEqual(grades[0].grade, 0.1, accuracy: 0.001)
        XCTAssertEqual(grades[1].grade, 0.15, accuracy: 0.01)
        XCTAssertEqual(grades[2].grade, 0.1, accuracy: 0.001)

        let second = try XCTUnwrap(grades[1].adjusted(grade: grades[0].grade + 0.01))
        XCTAssertEqual(0.11, second.grade, accuracy: 0.001)
        let third = try XCTUnwrap(GradeSegment(
            start: 200,
            end: 270,
            grade: second.grade - 0.01,
            elevationAtStart: second.elevationAtEnd
        ))
        XCTAssertEqual(0.1, third.grade, accuracy: 0.001)

        let expected: [GradeSegment] = [
            grades[0],
            second,
            third,
        ]

        let actual = try XCTUnwrap(grades.flatten(maxDelta: 0.01))
        XCTAssertNoDifference(expected, actual)
    }

    func testFlatteningGradeSegmentsWithVeryLargeGradeDifferencesDoesNotResultInNotANumber() throws {
        let track = try GPXFileParser(xmlString: .saCalobra).parse().get()

        let graph = TrackGraph(coords: .init(track.trackPoints.map(\.coordinate).prefix(50)))
        let actual = try XCTUnwrap(graph.gradeSegments.flatten(maxDelta: 0.01))

        XCTAssertNoDifference(0, actual.filter { $0.grade.isNaN }.count)
    }

    func testSmoothingElevationOnSmallCollections() {
        let start = Coordinate.leipzig.offset(elevation: 200)
        let end = start.offset(
            north: Double.random(in: 100 ... 1000),
            east: Double.random(in: 100 ... 1000),
            elevation: Double.random(in: 500 ... 550)
        )

        XCTAssertNoDifference([], [Coordinate]().smoothedElevation(sampleCount: Int.random(in: 2...200)))
        XCTAssertNoDifference([start], [start].smoothedElevation(sampleCount: Int.random(in: 5...200)))

        let coords: [Coordinate] = [start, end]
        let avg = coords.map(\.elevation).reduce(0, +) / Double(coords.count)

        XCTAssertNoDifference([.init(latitude: start.latitude, longitude: start.longitude, elevation: avg), .init(latitude: end.latitude, longitude: end.longitude, elevation: avg)], coords.smoothedElevation(sampleCount: 50))
    }
}
