import Foundation

public extension Collection where Element: GeoCoordinate {
    /// Creates a bounding box from a collection of `GeoCoordinate`s.
    /// - Returns: The 2D representation of the bounding box as `GeoBounds` value.
    func bounds() -> GeoBounds {
        reduce(GeoBounds.empty) { bounds, coord in
            GeoBounds(
                minLatitude: Swift.min(bounds.minLatitude, coord.latitude),
                minLongitude: Swift.min(bounds.minLongitude, coord.longitude),
                maxLatitude: Swift.max(bounds.maxLatitude, coord.latitude),
                maxLongitude: Swift.max(bounds.maxLongitude, coord.longitude)
            )
        }
    }
}

#if canImport(MapKit) && canImport(CoreLocation) && !os(watchOS)
import MapKit
import CoreLocation

public extension Collection where Element: GeoCoordinate {
    /// Creates a `MKPolyline` form a collection of `GeoCoordinates`
    ///
    /// Important: Only available on iOS and macOS targets.
    var polyLine: MKPolyline {
        let coords = map(CLLocationCoordinate2D.init)
        return MKPolyline(coordinates: coords, count: coords.count)
    }

    /// Creates a `CGPath` form a collection of `GeoCoordinates` using an MKMPolylineRenderer. Nil if no path could be created.
    /// 
    /// Important: Only available on iOS and macOS targets.
    var path: CGPath? {
        let renderer = MKPolylineRenderer(polyline: polyLine)
        return renderer.path
    }
}

#endif

#if canImport(CoreGraphics)
import CoreGraphics

public extension Collection where Element: GeoCoordinate {

    /// Creates a path from the collection of `GeoCoordinate`s. Useful if you want to draw a 2D image of a track.
    /// - Parameter normalized: Flag indicating if the paths values should be normalized into the range 0...1. If true, the resulting values in the path are mapped to value in 0...1 coordinates space, otherwise the values from the geo coordinates. Defaults to true.
    /// - Returns: A CGPath containing a projected 2D-representation of the geo coordinates.
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

    /// Helper for removing points from a collection if the are closer than a specified threshold.
    /// - Parameter meters: The threshold predicate in meters for removing points. A point is removed if it is closer to its predecessor than this value.
    /// - Returns: An array of `Coordinate` values, each having a minimum distance to their predecessors of least closerThan meters.
    ///
    /// Important: The elevation value of the returned `Coordinate` array is always zero.
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

public extension Array where Element == Coordinate {
    /// Helper for simplifying points from a collection if the are closer than a specified threshold.
    /// - Parameter threshold: The threshold predicate in for removing points. A point is removed if it is closer to its neighboring segment according to the [Ramer-Douglas-Peucker algorithm](https://en.wikipedia.org/wiki/Ramer–Douglas–Peucker_algorithm).
    /// - Returns: An array of `Coordinate` values.
    func simplifyRDP(threshold epsilon: Double) -> [Coordinate] {
        simplify(tolerance: epsilon)
    }
}
