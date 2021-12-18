import Foundation

/// A value describing a graph of a track. Contains metadata such as a `GPXTrack`s distance, elevation and a height-map.
public struct TrackGraph: Equatable {
    /// Array of `TrackSegment`s. The segments describe a tracks position along with its relative distance to its predecessor.
    public var segments: [TrackSegment]
    /// The overall distance of a track in meters.
    public var distance: Double
    /// The overall elevation gain of a track in meters.
    public var elevationGain: Double
    /// A heightmap, which is an array of `DistanceHeight` values. Each value in the heightMap has the total distance in meters up to that point (imagine it as the values along the x-axis in a 2D-coordinate graph) paired with the elevation in meters above sea level at that point (the y-value in the aforementioned 2D-graph).
    public var heightMap: [DistanceHeight]
    /// Array of `GradeSegment`s. The segments describe the grade over the entire track with specified interval length in meters in initializer.
    public var gradeSegments: [GradeSegment] = []

    /// Initialize for creating a `TrackGraph`  from `TrackPoint`s.
    /// - Parameters:
    ///   - points: Array of `TrackPoint` values.
    ///   - gradeSegmentLength: The length of the grade segments in meters. Defaults to 25 meters. Adjacent segments with the same grade will be joined together.
    public init(points: [TrackPoint], gradeSegmentLength: Double = 25.0) {
        self.init(coords: points.map { $0.coordinate }, gradeSegmentLength: gradeSegmentLength)
    }

    /// Initializer
    /// You don't need to construct this value by yourself, as it is done by GXPKits track parsing logic.
    /// - Parameters:
    ///   - segments: An array of `TrackSegment`s.
    ///   - distance: The total distance in meters.
    ///   - elevationGain: The total elevation gain.
    ///   - heightMap: The height-map
    @available(*, deprecated, message: "Will be removed in a future release, don't use it anymore!")
    public init(segments: [TrackSegment], distance: Double, elevationGain: Double, heightMap: [DistanceHeight]) {
        self.segments = segments
        self.distance = distance
        self.elevationGain = elevationGain
        self.heightMap = heightMap
        self.gradeSegments = [.init(start: 0, end: distance, grade: elevationGain/distance)]
    }
}


public extension TrackGraph {
    /// The elevation at a given distance. Elevations between coordinates will be interpolated from their adjacent track corrdinates.
    /// - Parameter distanceInMeters: The distance from the start of the track in meters. Must be in the range **{0, trackdistance}**.
    /// - Returns: The elevation in meters for a given distance or nil, if ```distanceInMeters``` is not within the tracks length.
    func elevation(at distanceInMeters: Double) -> Double? {
        guard (0...distance).contains(distanceInMeters),
              let index = heightMap.firstIndex(where: { $0.distance >= distanceInMeters  }) else { return nil }

        if heightMap[index].distance == distanceInMeters {
            return heightMap[index].elevation
        }
        let prev = heightMap[index-1]
        let next = heightMap[index]

        let distanceDelta = next.distance - prev.distance
        let heightDelta = next.elevation - prev.elevation
        let t = (distanceInMeters - prev.distance) / distanceDelta
        return prev.elevation + heightDelta * t
    }
}
