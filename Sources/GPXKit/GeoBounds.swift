import Foundation

/// A 2D-bounding box describing the area enclosing a track.
public struct GeoBounds: Hashable, Codable, Sendable {
    /// The minimum latitude value in degrees
    public var minLatitude: Double
    /// The minimum longitude value in degrees
    public var minLongitude: Double
    /// The maximum latitude value in degrees
    public var maxLatitude: Double
    /// The maximum longitude value in degrees
    public var maxLongitude: Double

    /// Initialized a GeoBounds value. You don't need to construct this value by yourself, as it is done by GXPKits track parsing logic.
    /// - Parameters:
    ///   - minLatitude: The minimum latitude value in degrees.
    ///   - minLongitude: The minimum longitude value in degrees.
    ///   - maxLatitude: The maximum latitude value in degrees.
    ///   - maxLongitude: The maximum longitude value in degrees.
    public init(minLatitude: Double, minLongitude: Double, maxLatitude: Double, maxLongitude: Double) {
        self.minLatitude = minLatitude
        self.minLongitude = minLongitude
        self.maxLatitude = maxLatitude
        self.maxLongitude = maxLongitude
    }
}

public extension GeoBounds {
    /// The _zero_ value of GeoBounds.
    ///
    /// Its values are not zero but contain the following values:
    /// ### minLatitude
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
