import Foundation

#if canImport(MapKit) && canImport(CoreLocation)
import MapKit
import CoreLocation

public extension Collection where Element: GeoCoordinate {
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

#if canImport(CoreGraphics)
import CoreGraphics

public extension Collection where Element: GeoCoordinate {
    func path(normalized: Bool = true) -> CGPath {
        var min = CGPoint(x: CGFloat.greatestFiniteMagnitude, y: CGFloat.greatestFiniteMagnitude)
        var max = CGPoint(x: -CGFloat.greatestFiniteMagnitude, y: -CGFloat.greatestFiniteMagnitude)
        var points: [CGPoint] = []
        points.reserveCapacity(count)
        for coord in self {
            let proj = coord.mercatorProjectionToDegrees()
            points.append(CGPoint(x: proj.x, y: proj.y))
            min.x = Swift.min(min.x, CGFloat(proj.x))
            min.y = Swift.min(min.y, CGFloat(proj.y))
            max.x = Swift.max(max.x, CGFloat(proj.x))
            max.y = Swift.max(max.y, CGFloat(proj.y))
        }
        let width = max.x - min.x
        let height = max.y - min.y
        let downScale: CGFloat = 1.0 / Swift.max(width, height)
        let scaleTransform = normalized ? CGAffineTransform(scaleX: downScale, y: downScale) : .identity
        let positionTransform = CGAffineTransform(translationX: -min.x, y: -min.y)
        let combined = positionTransform.concatenating(scaleTransform)
        let path = CGMutablePath()
        path.addLines(between: points, transform: combined)
        return path
    }
}
#endif

public extension Collection where Element: GeoCoordinate {
    func removeIf(closerThan meters: Double) -> [Coordinate] {
        guard count > 2 else { return map { Coordinate(latitude: $0.latitude, longitude: $0.longitude) } }

        return reduce([Coordinate(latitude: self[startIndex].latitude, longitude: self[startIndex].longitude)]) { coords, coord in
            if coords.last!.distance(to: coord) > meters {
                return coords + [Coordinate(latitude: coord.latitude, longitude: coord.longitude)]
            }
            return coords
        }
    }
}
