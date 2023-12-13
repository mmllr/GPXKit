import Foundation

public extension Collection where Element: GeoCoordinate {
    /// Creates a bounding box from a collection of ``GeoCoordinate``s.
    /// - Returns: The 2D representation of the bounding box as ``GeoBounds`` value.
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

public extension RandomAccessCollection where Element == Coordinate, Index == Int {
    func smoothedElevation(sampleCount: Int = 5) -> [Element] {
        guard self.count > 1 else { return Array(self) }
        let smoothingSize = (sampleCount / 2).clamped(to: .safe(lower: 2, upper: self.count / 2))

        return self.indices.reduce(into: [Element]()) { result, idx in
            let range = range(idx: idx, smoothingSize: smoothingSize, isLap: self.isLap)
            var updated = self[idx]
            updated.elevation = averageElevation(range: range)

            result.append(updated)
        }
    }
    
    /// Returns `true` if the distance between the first and the last is less than 50 meters. Returns `false` for empty collections.
    var isLap: Bool {
        guard let first, let last else { return false }
        return first.distance(to: last) < 50
    }

    private func range(idx: Int, smoothingSize: Int, isLap: Bool) -> ClosedRange<Int> {
        if isLap {
            idx - smoothingSize ... idx + smoothingSize
        } else {
            Swift.max(self.startIndex, idx - smoothingSize)...Swift.min(idx + smoothingSize, self.endIndex-1)
        }
    }

    private func averageElevation(range: ClosedRange<Int>) -> Double {
        if range.lowerBound >= self.startIndex && range.upperBound < self.endIndex {
            return self[range].map(\.elevation).reduce(0, +) / Double(range.count)
        }
        var average: Double = 0
        for idx in range {
            if idx < self.startIndex {
                average += self[(idx + self.count) % self.count].elevation
            } else if idx >= self.endIndex {
                average += self[idx % self.count].elevation
            } else {
                average += self[idx].elevation
            }
        }
        return average / Double(range.count)
    }
}

public extension [GradeSegment] {
    func flatten(maxDelta: Double) throws -> Self {
        guard !isEmpty else { return self }
        var result: [Element] = []
        for idx in self.indices {
            var segment = self[idx]
            if let previous = result.last {
                try segment.alignGrades(previous: previous, maxDelta: maxDelta)
            }
            result.append(segment)
        }
        return result
    }
}

extension GradeSegment {
    mutating func alignGrades(previous: GradeSegment, maxDelta: Double) throws {
        if elevationAtStart != previous.elevationAtEnd {
            let delta = (elevationAtStart - previous.elevationAtEnd)
            elevationAtStart -= delta
            elevationAtEnd -= delta
        }
        let deltaSlope = grade - previous.grade
        if abs(deltaSlope) > maxDelta {
            if deltaSlope >= 0 {
                try adjust(grade: previous.grade + maxDelta)
            } else if deltaSlope < 0 {
                try adjust(grade: previous.grade - maxDelta)
            }
            // TODO: Test me!
            if elevationAtStart < 0 {
                elevationAtStart = 0
            }
            if elevationAtEnd < 0 {
                elevationAtEnd = 0
            }
        }
    }
}


fileprivate extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }
}

extension ClosedRange {
    static func safe(lower: Bound, upper: Bound) -> Self {
        Swift.min(lower, upper) ... Swift.max(lower, upper)
    }
}
