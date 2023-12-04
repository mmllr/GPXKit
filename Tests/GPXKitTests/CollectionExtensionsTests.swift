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

    func testFlatteningGradeSegments() {
        let sut: [GradeSegment] = [
            .init(start: 0, end: 100, grade: 0.1, elevationAtStart: 50),
            .init(start: 100, end: 200, grade: 0.15, elevationAtStart: 60),
            GradeSegment(start: 200, end: 270, grade: 0.1, elevationAtStart: 65),
        ]

        XCTAssertNoDifference([
            GradeSegment(start: 0, end: 100, grade: 0.1, elevationAtStart: 50),
            GradeSegment(start: 100, end: 200, grade: 0.11, elevationAtStart: 60),
            GradeSegment(start: 200, end: 270, grade: 0.1, elevationAtStart: 71)

        ], sut.flatten(maxDelta: 0.01))
    }
}
