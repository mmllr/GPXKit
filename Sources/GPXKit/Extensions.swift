import Foundation

public extension GeoCoordinate {
    static var validLatitudeRange: ClosedRange<Double> { -90...90 }
    static var validLongitudeRange: ClosedRange<Double> { -180...180 }

    func distance(to: GeoCoordinate) -> Double {
        guard let dist = try? distanceVincenty(to: to) else { return calculateSimpleDistance(to: to) }
        return dist
    }

    // https://wiki.openstreetmap.org/wiki/Mercator
    func mercatorProjectionToMeters() -> (x: Double, y: Double) {
        let earthRadius: Double = 6_378_137.0 // meters
        let yInMeters: Double = log(tan(.pi / 4.0 + latitude.degreesToRadians / 2.0)) * earthRadius
        let xInMeters: Double = longitude.degreesToRadians * earthRadius
        return (x: xInMeters, y: -yInMeters)
    }

    func mercatorProjectionToDegrees() -> (x: Double, y: Double) {
        return (x: longitude, y: -log(tan(latitude.degreesToRadians / 2 + .pi / 4)).radiansToDegrees)
    }
}

public extension Array where Element: GeoCoordinate {
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

extension TrackPoint: GeoCoordinate {
    public var latitude: Double { coordinate.latitude }
    public var longitude: Double { coordinate.longitude }
}

public extension TrackGraph {
	init(coords: [Coordinate]) {
		let zippedCoords = zip(coords, coords.dropFirst())
		let distances: [Double] = [0.0] + zippedCoords.map {
			$0.distance(to: $1)
		}
		segments = zip(coords, distances).map {
			TrackSegment(coordinate: $0, distanceInMeters: $1)
		}
		distance = distances.reduce(0, +)
		elevationGain = zippedCoords.reduce(0.0) { elevation, pair in
			let delta = pair.1.elevation - pair.0.elevation
			if delta > 0 {
				return elevation + delta
			}
			return elevation
		}
        heightMap = segments.reduce((0.0, [DistanceHeight]())) { acc, segment in
            let distanceSoFar = acc.0 + segment.distanceInMeters
            let heightMap = acc.1 + [DistanceHeight(distance: distanceSoFar, elevation: segment.coordinate.elevation)]
            return (distanceSoFar, heightMap)
        }.1
	}
}

public extension TrackGraph {
    init(points: [TrackPoint]) {
        self.init(coords: points.map { $0.coordinate })
    }
}

public extension GPXFileParser {
    convenience init?(url: URL) {
        guard let xmlString = try? String(contentsOf: url) else { return nil }
        self.init(xmlString: xmlString)
    }

    convenience init?(data: Data) {
        guard let xmlString = String(data: data, encoding: .utf8) else { return nil }
        self.init(xmlString: xmlString)
    }
}

public extension GeoBounds {
    static let empty = GeoBounds(
        minLatitude: Coordinate.validLatitudeRange.upperBound,
        minLongitude: Coordinate.validLongitudeRange.upperBound,
        maxLatitude: Coordinate.validLatitudeRange.lowerBound,
        maxLongitude: Coordinate.validLongitudeRange.lowerBound
    )

    func intersects(_ rhs: GeoBounds) -> Bool {
        return (minLatitude...maxLatitude).overlaps(rhs.minLatitude...rhs.maxLatitude) &&
            (minLongitude...maxLongitude).overlaps(rhs.minLongitude...rhs.maxLongitude)
    }

    func contains(_ coordinate: GeoCoordinate) -> Bool {
        return (minLatitude...maxLatitude).contains(coordinate.latitude) &&
            (minLongitude...maxLongitude).contains(coordinate.longitude)
    }
}

public extension Collection where Element: GeoCoordinate {
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
