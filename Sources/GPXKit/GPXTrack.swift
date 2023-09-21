import Foundation

public enum ElevationSmoothing: Sendable {
    // length in meters
    case segmentation(Double)
    case smoothing(Int)
}

/// A value describing a track of geo locations. It has the recorded `TrackPoint`s, along with metadata of the track, such as recorded date, title, elevation gain, distance, height-map and bounds.
public struct GPXTrack: Hashable, Sendable {
    /// Optional date stamp of the gpx track
    public var date: Date?
    /// Waypoint defined for the gpx
    public var waypoints: [Waypoint]?
    /// Title of the gpx track
    public var title: String
    /// Description of the gpx track
    public var description: String?
    /// Array of latitude/longitude/elevation stream values
    public var trackPoints: [TrackPoint]
    /// `TrackGraph` containing elevation gain, overall distance and the height map of a track.
    public var graph: TrackGraph
    /// The bounding box enclosing the track
    public var bounds: GeoBounds
    /// Keywords describing a gpx track
    public var keywords: [String]

    /// Initializes a GPXTrack. You don't need to construct this value by yourself, as it is done by GXPKits track parsing logic.
    /// - Parameters:
    ///   - date: The date stamp of the track. Defaults to nil.
    ///   - waypoints: Array of `Waypoints`. Defaults to nil.
    ///   - title: String describing the track.
    ///   - trackPoints: Array of `TrackPoint`s describing the route.
    ///   - keywords: Array of `String`s with keywords. Default is an empty array (no keywords).
    ///   - gradeSegmentLength: The length in meters for the grade segments. Defaults to 50 meters.
    public init(date: Date? = nil, waypoints: [Waypoint]? = nil, title: String, description: String? = nil, trackPoints: [TrackPoint], keywords: [String] = [], elevationSmoothing: ElevationSmoothing = .segmentation(50)) {
        self.date = date
        self.waypoints = waypoints
        self.title = title
        self.description = description
        self.trackPoints = trackPoints
        self.graph = TrackGraph(points: trackPoints, elevationSmoothing: elevationSmoothing)
        self.bounds = trackPoints.bounds()
        self.keywords = keywords
    }
}
