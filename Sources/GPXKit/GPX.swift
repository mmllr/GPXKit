import Foundation

public enum ElevationSmoothing: Sendable, Hashable {
    case none
    // length in meters
    case segmentation(Double)
    case smoothing(Int)
    case combined(smoothingSampleCount: Int, maxGradeDelta: Double)
}


/// A value describing a track of geo locations. It has the recorded ``GPXPoint``s, along with metadata of the track, such as recorded date, title, elevation gain, distance, height-map and bounds.
public struct GPX: Hashable, Sendable {
    /// Optional date stamp of the gpx track
    public var date: Date?
    /// Waypoint defined for the gpx
    public var waypoints: [Waypoint]?
    /// Title of the gpx track
    public var title: String
    /// Description of the gpx track
    public var description: String?
    /// Array of tracks
    public var tracks: [GPXTrack]
    /// `TrackGraph` containing elevation gain, overall distance and the height map of a track.
    public var graph: TrackGraph
    /// The bounding box enclosing the track
    public var bounds: GeoBounds
    /// Keywords describing a gpx track
    public var keywords: [String]
    
    /// Initializes a GPXTrack.
    /// - Parameters:
    ///   - date: The date stamp of the track. Defaults to nil.
    ///   - waypoints: Array of ``Waypoint`` values. Defaults to nil.
    ///   - title: String describing the track.
    ///   - tracks: Array of ``GPXTrack``s describing the routes.
    ///   - keywords: Array of `String`s with keywords. Default is an empty array (no keywords).
    public init(date: Date? = nil, waypoints: [Waypoint]? = nil, title: String, description: String? = nil, tracks: [GPXTrack], keywords: [String] = []) {
        let trackPoints = tracks.flatMap{$0.trackPoints}
        self.date = date
        self.waypoints = waypoints
        self.title = title
        self.description = description
        self.tracks = tracks
        self.graph = TrackGraph(coords: trackPoints.map(\.coordinate))
        self.bounds = trackPoints.bounds()
        self.keywords = keywords
    }

    /// Initializes a GPXTrack. You don't need to construct this value by yourself, as it is done by GXPKits track parsing logic.
    /// - Parameters:
    ///   - date: The date stamp of the track. Defaults to nil.
    ///   - waypoints: Array of ``Waypoint`` values. Defaults to nil.
    ///   - title: String describing the track.
    ///   - tracks: Array of ``GPXTrack``s describing the routes.
    ///   - keywords: Array of `String`s with keywords. Default is an empty array (no keywords).
    ///   - elevationSmoothing: The ``ElevationSmoothing`` in meters for the grade segments. Defaults to ``ElevationSmoothing/segmentation(_:)`` with 50 meters.
    public init(date: Date? = nil, waypoints: [Waypoint]? = nil, title: String, description: String? = nil, tracks: [GPXTrack], keywords: [String] = [], elevationSmoothing: ElevationSmoothing = .segmentation(50)) throws {
        let trackPoints = tracks.flatMap{$0.trackPoints}
        self.date = date
        self.waypoints = waypoints
        self.title = title
        self.description = description
        self.tracks = tracks
        self.graph = try TrackGraph(points: trackPoints, elevationSmoothing: elevationSmoothing)
        self.bounds = trackPoints.bounds()
        self.keywords = keywords
    }
    
    public var trackPoints : [GPXPoint] {
        return self.tracks.flatMap{$0.trackPoints}
    }
}
