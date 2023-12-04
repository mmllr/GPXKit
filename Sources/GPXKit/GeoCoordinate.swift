import Foundation

/// Protocol for describing geo coordinates
///
/// Types that conform to the ``GeoCoordinate`` protocol can be used with GPXKits utility functions, for example distance or bounds calculations.
/// Adding ``GeoCoordinate`` conformance to your custom types means that your types must provide readable getters for latitude and longitude degree values.
public protocol GeoCoordinate {
    /// Latitude value in degrees
    var latitude: Double { get}
    /// Longitude value in degrees
    var longitude: Double { get }
}

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
    /// This produces a fast approximation to the truer, but heavier elliptical projection, where the Earth would be projected on a more accurate ellipsoid (flattened on poles). As a consequence, direct measurements of distances in this projection will be approximative, except on the Equator, and the aspect ratios on the rendered map for true squares measured on the surface on Earth will slightly change with latitude and angles not so precisely preserved by this spherical projection.
    /// [More details on Wikipedia](https://wiki.openstreetmap.org/wiki/Mercator)
    func mercatorProjectionToMeters() -> (x: Double, y: Double) {
        let earthRadius: Double = 6_378_137.0 // meters
        let yInMeters: Double = log(tan(.pi / 4.0 + latitude.degreesToRadians / 2.0)) * earthRadius
        let xInMeters: Double = longitude.degreesToRadians * earthRadius
        return (x: xInMeters, y: -yInMeters)
    }

    /// Performs a mercator projection of a geo coordinate to values in degrees
    /// - Returns: A pair of x/y-values in latitude/longitude degrees.
    ///
    /// This produces a fast approximation to the truer, but heavier elliptical projection, where the Earth would be projected on a more accurate ellipsoid (flattened on poles). As a consequence, direct measurements of distances in this projection will be approximative, except on the Equator, and the aspect ratios on the rendered map for true squares measured on the surface on Earth will slightly change with latitude and angles not so precisely preserved by this spherical projection.
    /// [More details on Wikipedia](https://wiki.openstreetmap.org/wiki/Mercator)
    func mercatorProjectionToDegrees() -> (x: Double, y: Double) {
        return (x: longitude, y: -log(tan(latitude.degreesToRadians / 2 + .pi / 4)).radiansToDegrees)
    }
}

public extension GeoCoordinate {
    /// Helper method for offsetting a ``GeoCoordinate``. Useful in tests or for tweaking a known location
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
