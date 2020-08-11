import XCTest
import GPXKit
#if canImport(CoreLocation)
import CoreLocation

extension TrackGraphTests {
    // MARK: Tests

    func testCLCoordinates2D() throws {
        guard #available(macOS 10.12, iOS 8, *) else {
            throw XCTSkip("Required API is not available for this test.")
        }
        let coordinates: [CLLocationCoordinate2D] = [
            CLLocationCoordinate2D(latitude: 51.2763320, longitude: 12.3767670),
            CLLocationCoordinate2D(latitude: 51.2763700, longitude: 12.3767550),
            CLLocationCoordinate2D(latitude: 51.2764100, longitude: 12.3767400),
            CLLocationCoordinate2D(latitude: 51.2764520, longitude: 12.3767260),
            CLLocationCoordinate2D(latitude: 51.2765020, longitude: 12.3767050),
        ]

        XCTAssertEqual(coordinates, sut.coreLocationCoordinates)
    }
}

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        if lhs.latitude != rhs.latitude {
            return false
        }
        return lhs.longitude == rhs.longitude
    }
}
#endif
