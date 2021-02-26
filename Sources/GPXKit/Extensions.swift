import Foundation

public extension GeoCoordinate {
    static var validLatitudeRange: ClosedRange<Double> { -90...90 }
    static var validLongitudeRange: ClosedRange<Double> { -180...180 }

    func distance(to: GeoCoordinate) -> Double {
        return calculateSimpleDistance(to: to)
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

public extension Coordinate {
    // https://gis.stackexchange.com/questions/2951/algorithm-for-offsetting-a-latitude-longitude-by-some-amount-of-meters
    func offset(north: Double = 0, east: Double = 0) -> Coordinate {
        // Earth’s radius, sphere
        let radius: Double = 6_378_137

        // Coordinate offsets in radians
        let dLat = north / radius
        let dLon = east / (radius * cos(.pi * latitude / 180))

        // OffsetPosition, decimal degrees
        return Coordinate(
            latitude: latitude + dLat * 180 / .pi,
            longitude: longitude + dLon * 180 / .pi
        )
    }
}
