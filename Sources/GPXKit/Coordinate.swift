import Foundation

/// Basic type for storing a geo location.
public struct Coordinate: GeoCoordinate, Hashable, Sendable {
    /// Latitude value in degrees
    public var latitude: Double
    /// Longitude value in degrees
    public var longitude: Double
    /// Elevation in meters
    public var elevation: Double = 0

    /// Initializer
    /// - Parameters:
    ///   - latitude: Latitude in degrees
    ///   - longitude: Longitude in degrees
    ///   - elevation: Elevation in meters, defaults to zero.
    public init(latitude: Double, longitude: Double, elevation: Double = .zero) {
        self.latitude = latitude
        self.longitude = longitude
        self.elevation = elevation
    }

    public static func == (lhs: Coordinate, rhs: Coordinate) -> Bool {
        (lhs.latitude - rhs.latitude).magnitude < 0.000001 &&
                (lhs.longitude - rhs.longitude).magnitude < 0.000001 &&
                (lhs.elevation - rhs.elevation).magnitude < 0.00001
    }
}
