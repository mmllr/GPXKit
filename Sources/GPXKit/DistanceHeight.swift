import Foundation

/// A value describing an entry in a ``TrackGraph``s height-map. It has the total distance in meters up to that point in the track along with the elevation in meters above sea level at that given point in a track (imagine the distance as the value along the x-axis in a 2D-coordinate graph, the elevation as the y-value).
public struct DistanceHeight: Hashable, Sendable {
    /// Total distance from the tracks start location in meters
    public var distance: Double
    /// Elevation in meters above sea level at that position in the track
    public var elevation: Double

    /// Initializes a ``DistanceHeight`` value. You don't need to construct this value by yourself, as it is done by GPXKits track parsing logic.
    /// - Parameters:
    ///   - distance: Distance from the tracks start location in meters.
    ///   - elevation: Elevation in meters above sea level at that track position.
    public init(distance: Double, elevation: Double) {
        self.distance = distance
        self.elevation = elevation
    }
}
