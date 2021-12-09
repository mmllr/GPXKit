import Foundation
#if canImport(CoreLocation)

import CoreLocation

public extension TrackGraph {
    /// Array of `CLLocationCoordinate2D` values from the `TrackGraph`s segments.
    var coreLocationCoordinates: [CLLocationCoordinate2D] {
        return segments.map {
            CLLocationCoordinate2D(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude)
        }
    }
}

public extension CLLocationCoordinate2D {
    /// Convenience initializer for creation of a `CLLocationCoordinate2D` from a `GeoCoordinate`
    /// - Parameter coord: A type which conforms to the `GeoCoordinate` protocol.
    init(_ coord: GeoCoordinate) {
		self.init(latitude: coord.latitude, longitude: coord.longitude)
    }
}

#endif
