import XCTest
import Foundation
import GPXKit

final class GeoBoundsTests: XCTestCase {
    func boundsWith(leftEdge: Double, topEdge: Double, size: Double) -> GeoBounds {
        let latRange = (leftEdge...(leftEdge + size)).clamped(to: Coordinate.validLatitudeRange)
        let lonRange = (topEdge...(topEdge + size)).clamped(to: Coordinate.validLongitudeRange)
        return GeoBounds(
            minLatitude: latRange.lowerBound,
            minLongitude: lonRange.lowerBound,
            maxLatitude: latRange.upperBound,
            maxLongitude: lonRange.upperBound)
    }

    func testIntersectionOfNonIntersectingBounds() {
        // lat: 20...40, lon: 20...40
        let sut = boundsWith(leftEdge: 20, topEdge: 20, size: 20)

        // at: 41...60, lon: 20...40 rhs is completely on sut's right edge
        XCTAssertFalse(sut.intersects(boundsWith(leftEdge: 41, topEdge: 20, size: 20)))

        // at: 5...15, lon: 20...30 rhs is completely on sut's left edge
        XCTAssertFalse(sut.intersects(boundsWith(leftEdge: 5, topEdge: 20, size: 10)))

        // at: 20...30, lon: -20...-10 rhs is completely above sut's top edge
        XCTAssertFalse(sut.intersects(boundsWith(leftEdge: 20, topEdge: -20, size: 10)))

        // at: 5...15, lon: 50...60 rhs is completely below sut's bottom edge
        XCTAssertFalse(sut.intersects(boundsWith(leftEdge: 5, topEdge: 50, size: 10)))
    }

    func testIntersectionOfOverlappingBounds() {
        // lat: 0...100, lon: 0...100
        let sut = boundsWith(leftEdge: 0, topEdge: 0, size: 100)

        // overlaps lat (41...141) & lon (20...120)
        XCTAssertTrue(sut.intersects(boundsWith(leftEdge: 41, topEdge: 20, size: 100)))
        // overlaps lat (-20...22) & lon (20...62)
        XCTAssertTrue(sut.intersects(boundsWith(leftEdge: -20, topEdge: 20, size: 42)))
        // overlaps lat (-40...20) & lon (-30...30)
        XCTAssertTrue(sut.intersects(boundsWith(leftEdge: 20, topEdge: -30, size: 60)))
    }

    func testBoundsFromRadius() throws {
        let bounds = try XCTUnwrap(Coordinate.leipzig.bounds(distanceInMeters: 10000))

        XCTAssertGreaterThan(Coordinate.leipzig.distance(to: Coordinate(latitude: bounds.minLatitude, longitude: bounds.minLongitude)), 8000)
        XCTAssertGreaterThan(Coordinate.leipzig.distance(to: Coordinate(latitude: bounds.maxLatitude, longitude: bounds.maxLatitude)), 8000)

        XCTAssertTrue(bounds.contains(Coordinate.leipzig))
        XCTAssertTrue(bounds.contains(Coordinate.dehner))
        XCTAssertTrue(bounds.contains(Coordinate.kreisel))
        XCTAssertFalse(bounds.contains(Coordinate.postPlatz))
        try XCTAssertTrue(XCTUnwrap(Coordinate.leipzig.bounds(distanceInMeters: 100000)).contains(Coordinate.postPlatz))
    }
}
