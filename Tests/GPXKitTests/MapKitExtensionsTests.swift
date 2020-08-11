import Foundation
@testable import GPXKit
import XCTest

#if canImport(MapKit) && canImport(CoreLocation)
import MapKit
import CoreLocation

final class CoordinateExtensionTests: XCTestCase {
    func testPolyLine() {
        let coordinates: [Coordinate] = [
            Coordinate(latitude: 51.2763320, longitude: 12.3767670, elevation: 82.2),
            Coordinate(latitude: 53.2763700, longitude: 11.3767550, elevation: 82.2),
            Coordinate(latitude: 54.2764100, longitude: 10.3767400, elevation: 82.2),
            Coordinate(latitude: 55.2764520, longitude: 9.3767260, elevation: 82.2),
            Coordinate(latitude: 57.2765020, longitude: 8.3767050, elevation: 82.2),
        ]

        let polyline = coordinates.polyLine
        let points = Array(UnsafeBufferPointer(start: polyline.points(), count: polyline.pointCount))
        let expected = coordinates.map(CLLocationCoordinate2D.init)
        assertGeoCoordinatesEqual(expected, points.map { $0.coordinate }, accuracy: 0.0001)
    }
}

extension CLLocationCoordinate2D: GeoCoordinate { }

#endif
