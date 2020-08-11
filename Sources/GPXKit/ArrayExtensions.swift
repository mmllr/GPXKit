import Foundation

#if canImport(MapKit) && canImport(CoreLocation)
import MapKit
import CoreLocation

public extension Array where Element: GeoCoordinate {
    var polyLine: MKPolyline {
        let coords = map(CLLocationCoordinate2D.init)
        return MKPolyline(coordinates: coords, count: coords.count)
    }

    var path: CGPath? {
        let renderer = MKPolylineRenderer(polyline: polyLine)
        return renderer.path
    }
}

#endif
