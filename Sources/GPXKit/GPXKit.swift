import Foundation

/// Protocol for describing geo coordinates
///
/// Types that conform to the `GeoCoordinate` protocol can be used with GPXKits utility functions, for example distance or bounds calculations.
/// Adding `GeoCoordinate` conformance to your custom types means that your types must provide readable getters for latitude and longitude degree values.
public protocol GeoCoordinate {
    /// Latitude value in degrees
    var latitude: Double { get}
    /// Longitude value in degrees
    var longitude: Double { get }
}

/// Basic type for storing a geo location.
public struct Coordinate: Hashable, GeoCoordinate {
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
}

/// Value type descriping a logical segment in a `TrackGraph`. A `TrackGraph` consists of a collection of `TrackSegment`s. Each has a coordinate (latitude, longitude & elevation) and the distance (in meters) to its preceding segment point.
public struct TrackSegment: Hashable {
    /// The coordinate (latitude, longitude and elevation)
    public var coordinate: Coordinate

    /// Distance in meters to its preceeding `TrackSegment` in a `TrackGraph`
    public var distanceInMeters: Double

    /// Initilizes a `TrackSegment`
    /// You don't need to construct this value by yourself, as it is done by GXPKits track parsing logic.
    /// - Parameters:
    ///   - coordinate: A `Coordinate` struct, contains latitude/longitude and elevation
    ///   - distanceInMeters: Distance in meters to its preceeding `TrackSegment` in a `TrackGraph`
    public init(coordinate: Coordinate, distanceInMeters: Double) {
        self.coordinate = coordinate
        self.distanceInMeters = distanceInMeters
    }
}

/// A value describing a single data point in a `GPXTrack`. A `TrackPoint` has the latitude, longitude and elevation data along with meta data such as a timestamp or power values.
public struct TrackPoint: Hashable {
    /// The coordinate (latitude, longitude and elevation in meters)
    public var coordinate: Coordinate
    /// Optional date for a given point. This is the date stamp from a gpx file, recorded from a bicycle computer or running watch.
    public var date: Date?
    /// Optional power value for a given point in a gpx file, which got recorded from a bicycle computer through a power meter.
    public var power: Measurement<UnitPower>?

    /// Initilizer
    /// You don't need to construct this value by yourself, as it is done by GXPKits track parsing logic.
    /// - Parameters:
    ///   - coordinate: The coordinate (latitude, longitude and elevation in meters)
    ///   - date: Optional date for a point. Defaults to nil.
    ///   - power: Optional power value for a point. Defaults to nil.
    public init(coordinate: Coordinate, date: Date? = nil, power: Measurement<UnitPower>? = nil) {
        self.coordinate = coordinate
        self.date = date
        self.power = power
    }
}

/// A value describing a graph of a track. Contains metadata such as a `GPXTrack`s distance, elevation and a heightmap.
public struct TrackGraph: Equatable {
    /// Array of `TrackSegment`s. The segments describe a tracks position along with its relative distance to its predecessor.
    public var segments: [TrackSegment]
    /// The overall distance of a track in meters.
    public var distance: Double
    /// The overall elevation gain of a track in meters.
    public var elevationGain: Double
    /// A heightmap, which is an array of `DistanceHeight` values. Each value in the heightMap has the total distance in meters up to that point (imagine it as the values along the x-axis in a 2D-coordinate graph) paired with the elevation in meters above sea level at that point (the y-value in the afforementioned 2D-graph).
    public var heightMap: [DistanceHeight]

    /// Initializer
    /// You don't need to construct this value by yourself, as it is done by GXPKits track parsing logic.
    /// - Parameters:
    ///   - segments: An array of `TrackSegment`s.
    ///   - distance: The total distance in meters.
    ///   - elevationGain: The total elevation gain.
    ///   - heightMap: The heightmap
    public init(segments: [TrackSegment], distance: Double, elevationGain: Double, heightMap: [DistanceHeight]) {
        self.segments = segments
        self.distance = distance
        self.elevationGain = elevationGain
        self.heightMap = heightMap
    }
}

/// A value describing an entry in a `TrackGraph`s heightmap. It has the totoal distance in meters up to that point in the track along with the elevation in meters above sea level at that given point in a track (imagine the dictance as the value along the x-axis in a 2D-coordinate graph, the elevation as the y-value).
public struct DistanceHeight: Hashable {
    /// Total distance from the tracks start location in meters
    public var distance: Double
    /// Elevation in meters above sea level at that position in the track
    public var elevation: Double

    /// Initializes a `DistanceHeight` value. You don't need to construct this value by yourself, as it is done by GXPKits track parsing logic.
    /// - Parameters:
    ///   - distance: Distance from the tracks start location in meters.
    ///   - elevation: Elevation in meters above sea level at that track position.
    public init(distance: Double, elevation: Double) {
        self.distance = distance
        self.elevation = elevation
    }
}

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

/// A value describing an track of geo locations. It has the recorded `TrackPoint`s, along with metadata of the track, such as recorded date, title, elevation gain, distance, heightmap and bounds.
public struct GPXTrack: Equatable {
    /// Optional date stamp of the gpx track
    public var date: Date?
    /// Title of the gpx track
    public var title: String
    /// Array of latitude/longitutde/elevation stream values
    public var trackPoints: [TrackPoint]
    /// `TrackGraph` containg elevation gain, overall distance and the height map of a track.
    public var graph: TrackGraph
    /// The bounding box enclosing the track
    public var bounds: GeoBounds

    /// Initializes a GPXTrack. You don't need to construct this value by yourself, as it is done by GXPKits track parsing logic.
    /// - Parameters:
    ///   - date: The date stamp of the track. Defaults to nil.
    ///   - title: String describing the track.
    ///   - trackPoints: Array of `TrackPoint`s describing the route.
    public init(date: Date? = nil, title: String, trackPoints: [TrackPoint]) {
        self.date = date
        self.title = title
        self.trackPoints = trackPoints
        self.graph = TrackGraph(points: trackPoints)
        self.bounds = trackPoints.bounds()
    }
}

/// Describes a climb section within a track.
public struct Climb: Hashable {
    /// The distance in meters from the climbs start to the `GPXTrack`s origin.
    public var start: Double
    /// The distance of the end climb in meters from the `GPXTrack`s origin.
    public var end: Double
    /// The elevation in meters of the climbs bottom.
    public var bottom: Double
    /// The elevation in meters of the climbs top.
    public var top: Double
    /// The grade of the climb in percent in the range {0,1}.
    public var grade: Double
    /// The FIETS score of the climb
    /// 
    /// One way to determine the difficulty of a climb is to use the FIETS formula to calculate a numeric value for the climb. This forumula was developed by the Dutch cycling magazine Fiets. The formula is shown below:
    ///
    /// ```
    /// FIETS Score = (H * H / D * 10) + (T - 1000) / 1000
    /// ```
    /// Where:

    /// * **H** is the height of the climb (meters),
    /// * **D** is the climb length or distance (meters)
    /// * **T** is the altitude at the top (meters).

    /// The second term in the formula is only added when it is positive, thay is, for climbs whose top is above 1000m.
    /// **NOTE** In GPXKit, the "(T - 1000)/1000" term of the FIETS formula is not added to the climb segments, so climbs can be joined together.
    public var score: Double
}
}
