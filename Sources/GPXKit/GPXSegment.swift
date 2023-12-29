import Foundation

/// A value describing a segment of geo locations
public struct GPXSegment: Hashable, Sendable {
    /// Array of latitude/longitude/elevation stream values
    public var trackPoints: [GPXPoint]
    
    /// Initializer
    /// You don't need to construct this value by yourself, as it is done by GXPKits track parsing logic.
    /// - Parameters:
    ///   - trackPoints: Array of ``GPXPoint``s describing the route.
    public init(trackPoints: [GPXPoint]) {
        self.trackPoints = trackPoints
    }
}
