//
// GPXKit - MIT License - Copyright © 2024 Markus Müller. All rights reserved.
//

import Foundation
import GPXKit
import Numerics
import Testing

struct GeoCoordinateExtensionsTests {
    @Test(arguments: 1 ... 180)
    func testRadiusForDelta(value: Int) {
        let degree = Double(value)
        let location = Coordinate(latitude: 51.323331, longitude: 12.368279, elevation: 110)

        let expected = degree * 111.045 / 2.0 * 1000
        //  one degree of latitude is always approximately 111 kilometers (69 miles)
        #expect(
            expected.isApproximatelyEqual(to: location.radiusInMeters(latitudeDelta: degree), absoluteTolerance: 139 * degree),
            "Radius \(location.radiusInMeters(latitudeDelta: degree)) for \(degree) not in expected range \(expected)"
        )
    }
}
