import Foundation
#if canImport(CoreLocation)

import CoreLocation

public extension TrackGraph {
    var coreLocationCoordinates: [CLLocationCoordinate2D] {
        return segments.map {
            CLLocationCoordinate2D(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude)
        }
    }
}

public extension CLLocationCoordinate2D {
    init(_ coord: GeoCoordinate) {
		self.init(latitude: coord.latitude, longitude: coord.longitude)
    }
}

#endif
