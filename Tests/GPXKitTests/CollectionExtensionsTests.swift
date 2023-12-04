import Foundation
import XCTest
import GPXKit
import CustomDump

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
            .postPlatz
        ]

        let result = coords.removeIf(closerThan: 50)
        XCTAssertNoDifference([coords[0], coords[1], coords[3], .postPlatz], result)
    }
}

