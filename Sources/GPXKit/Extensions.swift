import Foundation

public extension GeoCoordinate {
    /// A range of valid latitude values (from -90 to 90 degrees)
    static var validLatitudeRange: ClosedRange<Double> { -90...90 }
    /// A range of valid longitude values (from -180 to 180 degrees)
    static var validLongitudeRange: ClosedRange<Double> { -180...180 }

    /// Calculates the distance in meters to another `GeoCoordinate`.
    /// - Parameter to: Destination coordinate (given latitude & longitude degrees) to which the distance should be calculated.
    /// - Returns: Distance in meters.
    func distance(to: GeoCoordinate) -> Double {
        return calculateHaversineDistance(to: to)
    }

    /// Performs a mercator projection of a geo coordinate to values in meters along x/y
    /// - Returns: A pair of x/y-values in meters.
    ///
    /// This produces a fast approximation to the truer, but heavier elliptical projection, where the Earth would be projected on a more accurate ellipsoid (flattened on poles). As a consequence, direct mesurements of distances in this projection will be approximative, except on the Equator, and the aspect ratios on the rendered map for true squares measured on the surface on Earth will slightly change with latitude and angles not so precisely preserved by this spherical projection.
    /// [More details on Wikipedia](https://wiki.openstreetmap.org/wiki/Mercator)
    func mercatorProjectionToMeters() -> (x: Double, y: Double) {
        let earthRadius: Double = 6_378_137.0 // meters
        let yInMeters: Double = log(tan(.pi / 4.0 + latitude.degreesToRadians / 2.0)) * earthRadius
        let xInMeters: Double = longitude.degreesToRadians * earthRadius
        return (x: xInMeters, y: -yInMeters)
    }

    /// Performs a mercator projection of a geo coordinate to values in degrees
    /// - Returns: A pair of x/y-values in lagtitude/longitude degrees.
    ///
    /// This produces a fast approximation to the truer, but heavier elliptical projection, where the Earth would be projected on a more accurate ellipsoid (flattened on poles). As a consequence, direct mesurements of distances in this projection will be approximative, except on the Equator, and the aspect ratios on the rendered map for true squares measured on the surface on Earth will slightly change with latitude and angles not so precisely preserved by this spherical projection.
    /// [More details on Wikipedia](https://wiki.openstreetmap.org/wiki/Mercator)
    func mercatorProjectionToDegrees() -> (x: Double, y: Double) {
        return (x: longitude, y: -log(tan(latitude.degreesToRadians / 2 + .pi / 4)).radiansToDegrees)
    }
}

extension TrackPoint: GeoCoordinate {
    public var latitude: Double { coordinate.latitude }
    public var longitude: Double { coordinate.longitude }
}

public extension TrackGraph {
    /// Convenience initialize for creating a `TrackGraph`  from `Coordinate`s.
    /// - Parameter coords: Array of `Coordinate` values.
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
    /// Convenience initialize for creating a `TrackGraph`  from `TrackPoint`s.
    /// - Parameter points: Array of `TrackPoint` values.
    init(points: [TrackPoint]) {
        self.init(coords: points.map { $0.coordinate })
    }
}

public extension GPXFileParser {
    /// Convenience initialize for loading a GPX file from an url. Fails if the track cannot be parsed.
    /// - Parameter url: The url containing the GPX file. See [GPX specification for details](https://www.topografix.com/gpx.asp).
    /// - Returns: An `GPXFileParser` instance or nil if the track cannot be parsed.
    convenience init?(url: URL) {
        guard let xmlString = try? String(contentsOf: url) else { return nil }
        self.init(xmlString: xmlString)
    }

    /// Convenience initialize for loading a GPX file from a data. Returns nil if the track cannot be parsed.
    /// - Parameter data: Data containing the GPX file as encoded xml string. See [GPX specification for details](https://www.topografix.com/gpx.asp).
    /// - Returns: An `GPXFileParser` instance or nil if the track cannot be parsed.
    convenience init?(data: Data) {
        guard let xmlString = String(data: data, encoding: .utf8) else { return nil }
        self.init(xmlString: xmlString)
    }
}

public extension GeoBounds {
    /// The _zero_ value of GeoBounds.
    ///
    /// Its values are not zero but contain the follwing values:
    /// ### minLatitute
    /// `Coordinate.validLatitudeRange.upperBound`
    /// ### minLongitude
    /// `Coordinate.validLongitudeRange.upperBound`
    /// ### maxLatitude
    /// `Coordinate.validLatitudeRange.lowerBound`
    /// #### maxLongitude
    /// `Coordinate.validLongitudeRange.lowerBound`
    ///
    /// See `Coordinate.validLongitudeRange` & `Coordinate.validLatitudeRange.upperBound` for details.
    static let empty = GeoBounds(
        minLatitude: Coordinate.validLatitudeRange.upperBound,
        minLongitude: Coordinate.validLongitudeRange.upperBound,
        maxLatitude: Coordinate.validLatitudeRange.lowerBound,
        maxLongitude: Coordinate.validLongitudeRange.lowerBound
    )

    /// Tests if two `GeoBound` values intersects
    /// - Parameter rhs: The other `GeoBound` to test for intersection.
    /// - Returns: True if both bounds intersect, otherwise false.
    func intersects(_ rhs: GeoBounds) -> Bool {
        return (minLatitude...maxLatitude).overlaps(rhs.minLatitude...rhs.maxLatitude) &&
            (minLongitude...maxLongitude).overlaps(rhs.minLongitude...rhs.maxLongitude)
    }

    /// Tests if a `GeoCoordinate` is within a `GeoBound`
    /// - Parameter coordinate: The `GeoCoordinate` to test for.
    /// - Returns: True if coordinate is within the bounds otherwise false.
    func contains(_ coordinate: GeoCoordinate) -> Bool {
        return (minLatitude...maxLatitude).contains(coordinate.latitude) &&
            (minLongitude...maxLongitude).contains(coordinate.longitude)
    }
}

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

public extension GeoCoordinate {
    /// Helper method for offsetting a `GeoCoordinate`. Useful in tests or for tweaking a known location
    /// - Parameters:
    ///   - north: The offset in meters in _vertical_ direction as seen on a map. Use negative values to go _upwards_ on a globe, positive values for moving downwards.
    ///   - east: The offset in meters in _horizontal_ direction as seen on a map. Use negative values to go to the _west_ on a globe, positive values for moving in the _eastern_ direction.
    /// - Returns: A new `Coordinate` value, offset by north and east values in meters.
    ///
    /// ```swift
    /// let position = Coordinate(latitude: 51.323331, longitude: 12.368279)
    /// position.offset(east: 60),
    /// position.offset(east: -100),
    /// position.offset(north: 120),
    /// position.offset(north: -160),
    /// ```
    /// 
    /// See [here](https://gis.stackexchange.com/questions/2951/algorithm-for-offsetting-a-latitude-longitude-by-some-amount-of-meters) for more details.
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

public extension GeoCoordinate {

    /// Calculates the bearing of the coordinate to a second
    /// - Parameter target: The second coordinate
    /// - Returns: The bearing to `target`in degrees
    func bearing(target: Coordinate) -> Double {
        let lat1 = latitude.degreesToRadians
        let lon1 = longitude.degreesToRadians
        let lat2 = target.latitude.degreesToRadians
        let lon2 = target.longitude.degreesToRadians

        let dLon = lon2 - lon1

        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)

        return radiansBearing.radiansToDegrees
    }
}
