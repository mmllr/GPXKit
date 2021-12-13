import Foundation

/// A 2D-bounding box describing the area enclosing a track.
public struct GeoBounds: Hashable, Codable {
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