import Foundation
import CoreLocation


public extension TrackGraph {
    var coreLocationCoordinates: [CLLocationCoordinate2D] {
        return segments.map {
            CLLocationCoordinate2D(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude)
        }
    }
}

public extension TrackGraph {
    init(points: [TrackPoint]) {
		self.init(coords: points.map { $0.coordinate })
    }
}

public extension CLLocationCoordinate2D {
    init(_ coord: Coordinate) {
		self.init(latitude: coord.latitude, longitude: coord.longitude)
    }
}
