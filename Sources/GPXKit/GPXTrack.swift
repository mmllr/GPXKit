import Foundation

/// A value describing a track of geo locations
public struct GPXTrack: Hashable, Sendable {
    /// Array of track segments
    public var trackSegments: [GPXSegment]
    
    
    /// Initializer
    /// You don't need to construct this value by yourself, as it is done by GXPKits track parsing logic.
    /// - Parameters:
    ///   - trackSegments: Array of ``GPXSegment``s describing the route.
    public init(trackSegments: [GPXSegment]) {
        self.trackSegments = trackSegments
    }
    
    public var trackPoints : [GPXPoint] {
        return self.trackSegments.flatMap{$0.trackPoints}
    }
}
