import Foundation
import XCTest
import GPXKit

final class ArrayExtensionsTests: XCTestCase {
    func testRemovingNearbyCoordinatesInEmptyCollection() {
        let coords: [Coordinate] = []

        XCTAssertEqual([], coords.removeIf(closerThan: 1))
    }

    func testRemovingNearbyCoordinatesWithOneElement() {
        let coords: [Coordinate] = [.leipzig]

        XCTAssertEqual([.leipzig], coords.removeIf(closerThan: 1))
    }

    func testRemovingNearbyCoordinatesWithtwoElement() {
        let coords: [Coordinate] = [.leipzig, .dehner]

        XCTAssertEqual([.leipzig, .dehner], coords.removeIf(closerThan: 1))
    }

    func testRemovingDuplicateCoordinates() {
        let start = Coordinate.leipzig
        let coords: [Coordinate] = [
            start,
            start.offset(east: 60),
            start.offset(east: 100),
            start.offset(north: 120),
            start.offset(north: 160),
            .postPlatz
        ]

        let result = coords.removeIf(closerThan: 50)
        XCTAssertEqual([coords[0], coords[1], coords[3], .postPlatz], result)
    }
}

