import Foundation

/// A value describing a track of geo locations
public struct GPXTrack: Hashable, Sendable {
    /// Name of the gpx track
    public var name: String?
    /// Description of the gpx track
    public var description: String?
    /// Array of track segments
    public var trackSegments: [GPXSegment]
    
    
    /// Initializer
    /// You don't need to construct this value by yourself, as it is done by GXPKits track parsing logic.
    /// - Parameters:
    ///   - name: String title of the track.
    ///   - description: String description of the track
    ///   - trackSegments: Array of ``GPXSegment``s describing the route.
    public init(name: String? = nil, description: String? = nil, trackSegments: [GPXSegment] = []) {
        self.name = name
        self.description = description
        self.trackSegments = trackSegments
    }
    
    public var trackPoints : [GPXPoint] {
        return self.trackSegments.flatMap{$0.trackPoints}
    }
}
