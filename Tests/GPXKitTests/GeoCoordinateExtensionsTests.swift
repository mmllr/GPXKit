import Foundation
import GPXKit
import XCTest

final class GeoCoordinateExtensionsTests: XCTestCase {
    func testRadiusForDelta() {
        let location = Coordinate(latitude: 51.323331, longitude: 12.368279, elevation: 110)

        for degree in stride(from: 1.0, to: 180.0, by: 1) {
            let expected = degree * 111.045 / 2.0 * 1000
            //  one degree of latitude is always approximately 111 kilometers (69 miles)
            XCTAssertEqual(
                expected,
                location.radiusInMeters(latitudeDelta: degree),
                accuracy: 139 * degree,
                "Radius \(location.radiusInMeters(latitudeDelta: degree)) for \(degree) not in expected range \(expected)"
            )
        }
    }
}
