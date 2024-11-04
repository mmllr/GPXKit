//
// GPXKit - MIT License - Copyright © 2024 Markus Müller. All rights reserved.
//

import Foundation
import GPXKit
import Testing

@Suite
struct GeoBoundsTests {
    func boundsWith(leftEdge: Double, topEdge: Double, size: Double) -> GeoBounds {
        let latRange = (leftEdge ... (leftEdge + size)).clamped(to: Coordinate.validLatitudeRange)
        let lonRange = (topEdge ... (topEdge + size)).clamped(to: Coordinate.validLongitudeRange)
        return GeoBounds(
            minLatitude: latRange.lowerBound,
            minLongitude: lonRange.lowerBound,
            maxLatitude: latRange.upperBound,
            maxLongitude: lonRange.upperBound
        )
    }

    @Test
    func testIntersectionOfNonIntersectingBounds() {
        // lat: 20...40, lon: 20...40
        let sut = boundsWith(leftEdge: 20, topEdge: 20, size: 20)

        // at: 41...60, lon: 20...40 rhs is completely on sut's right edge
        #expect(sut.intersects(boundsWith(leftEdge: 41, topEdge: 20, size: 20)) == false)

        // at: 5...15, lon: 20...30 rhs is completely on sut's left edge
        #expect(sut.intersects(boundsWith(leftEdge: 5, topEdge: 20, size: 10)) == false)

        // at: 20...30, lon: -20...-10 rhs is completely above sut's top edge
        #expect(sut.intersects(boundsWith(leftEdge: 20, topEdge: -20, size: 10)) == false)

        // at: 5...15, lon: 50...60 rhs is completely below sut's bottom edge
        #expect(sut.intersects(boundsWith(leftEdge: 5, topEdge: 50, size: 10)) == false)
    }

    @Test
    func testIntersectionOfOverlappingBounds() {
        // lat: 0...100, lon: 0...100
        let sut = boundsWith(leftEdge: 0, topEdge: 0, size: 100)

        // overlaps lat (41...141) & lon (20...120)
        #expect(sut.intersects(boundsWith(leftEdge: 41, topEdge: 20, size: 100)))
        // overlaps lat (-20...22) & lon (20...62)
        #expect(sut.intersects(boundsWith(leftEdge: -20, topEdge: 20, size: 42)))
        // overlaps lat (-40...20) & lon (-30...30)
        #expect(sut.intersects(boundsWith(leftEdge: 20, topEdge: -30, size: 60)))
    }

    @Test
    func testBoundsFromRadius() throws {
        let bounds = try #require(Coordinate.leipzig.bounds(distanceInMeters: 10000))

        #expect(Coordinate.leipzig.distance(to: Coordinate(latitude: bounds.minLatitude, longitude: bounds.minLongitude)) > 8000)
        #expect(Coordinate.leipzig.distance(to: Coordinate(latitude: bounds.maxLatitude, longitude: bounds.maxLatitude)) > 8000)

        #expect(bounds.contains(Coordinate.leipzig))
        #expect(bounds.contains(Coordinate.dehner))
        #expect(bounds.contains(Coordinate.kreisel))
        #expect(bounds.contains(Coordinate.postPlatz) == false)
        try #expect(#require(Coordinate.leipzig.bounds(distanceInMeters: 100000)).contains(Coordinate.postPlatz))
    }
}
