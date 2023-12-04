import Foundation

/// A value describing a graph of a track. Contains metadata such as a `GPXTrack`s distance, elevation and a height-map.
public struct TrackGraph: Hashable, Sendable {
    /// Array of ``TrackSegment`` values. The segments describe a tracks position along with its relative distance to its predecessor.
    public var segments: [TrackSegment]
    /// The overall distance of a track in meters.
    public var distance: Double
    /// The overall elevation gain of a track in meters.
    public var elevationGain: Double
    /// A heightmap, which is an array of ``DistanceHeight`` values. Each value in the heightMap has the total distance in meters up to that point (imagine it as the values along the x-axis in a 2D-coordinate graph) paired with the elevation in meters above sea level at that point (the y-value in the aforementioned 2D-graph).
    public var heightMap: [DistanceHeight]
    /// Array of `GradeSegment`s. The segments describe the grade over the entire track with specified interval length in meters in initializer.
    public var gradeSegments: [GradeSegment] = []

    /// Initialize for creating a `TrackGraph`  from `TrackPoint`s.
    /// - Parameters:
    ///   - points: Array of `TrackPoint` values.
    ///   - gradeSegmentLength: The length of the grade segments in meters. Defaults to 25 meters. Adjacent segments with the same grade will be joined together.
    public init(points: [TrackPoint], elevationSmoothing: ElevationSmoothing = .segmentation(50)) {
        self.init(coords: points.map { $0.coordinate }, elevationSmoothing: elevationSmoothing)
    }

    /// Initializer
    /// You don't need to construct this value by yourself, as it is done by GXPKits track parsing logic.
    /// - Parameters:
    ///   - segments: An array of ``TrackSegment``s.
    ///   - distance: The total distance in meters.
    ///   - elevationGain: The total elevation gain.
    ///   - heightMap: The height-map
    @available(*, deprecated, message: "Will be removed in a future release, don't use it anymore!")
    public init(segments: [TrackSegment], distance: Double, elevationGain: Double, heightMap: [DistanceHeight]) {
        self.segments = segments
        self.distance = distance
        self.elevationGain = elevationGain
        self.heightMap = heightMap
        self.gradeSegments = [.init(start: 0, end: distance, grade: elevationGain/distance, elevationAtStart: 0)]
    }
}


public extension TrackGraph {
    /// The elevation at a given distance. Elevations between coordinates will be interpolated from their adjacent track corrdinates.
    /// - Parameter distanceInMeters: The distance from the start of the track in meters. Must be in the range **{0, trackdistance}**.
    /// - Returns: The elevation in meters for a given distance or nil, if ```distanceInMeters``` is not within the tracks length.
    func elevation(at distanceInMeters: Double) -> Double? {
        heightMap.height(at: distanceInMeters)
    }
}

public extension TrackGraph {
    /// Convenience initialize for creating a ``TrackGraph``  from ``Coordinate``s.
    /// - Parameter coords: Array of ``Coordinate`` values.
    /// - Parameter elevationSmoothing: The ``ElevationSmoothing`` for calculating the elevation grades..
    init(coords: [Coordinate], elevationSmoothing: ElevationSmoothing) {
        let zippedCoords = zip(coords, coords.dropFirst())
        let distances: [Double] = [0.0] + zippedCoords.map {
            $0.distance(to: $1)
        }

        segments = zip(coords, distances).map {
            TrackSegment(coordinate: $0, distanceInMeters: $1)
        }
        distance = distances.reduce(0, +)
        elevationGain = coords.calculateElevationGain()
        let heightmap = segments.reduce(into: [DistanceHeight]()) { acc, segment in
            let distanceSoFar = (acc.last?.distance ?? 0) + segment.distanceInMeters
            acc.append(DistanceHeight(distance: distanceSoFar, elevation: segment.coordinate.elevation))
        }
        self.heightMap = heightmap
        self.gradeSegments = heightmap.calculateGradeSegments(elevationSmoothing)
    }
}

public extension TrackGraph {
    /// Calculates the ``TrackGraph``s climbs.
    /// - Parameters:
    ///   - epsilon: The simplification factor in meters for smoothing out elevation jumps. Defaults to 1.
    ///   - minimumGrade: The minimum allowed grade in percent in the Range {0,1}. Defaults to 0.03 (3%).
    ///   - maxJoinDistance:The maximum allowed distance between climb segments in meters. If ``Climb`` segments are closer they will get joined to one climb. Defaults to 0.
    /// - Returns: An array of ``Climb`` values. Returns an empty array if no climbs where found.
    func climbs(epsilon: Double = 1, minimumGrade: Double = 0.03, maxJoinDistance: Double = 0) -> [Climb] {
        guard
            heightMap.count > 1
        else {
            return []
        }
        return findClimbs(epsilon: epsilon, minimumGrade: minimumGrade, maxJoinDistance: maxJoinDistance)
    }
}

private extension Collection<Coordinate> {
    /// Calculates the elevation gain by applying a threshold to reduce vertical noise.
    ///
    /// See https://www.gpsvisualizer.com/tutorials/elevation_gain.html for more details
    /// - Parameters:
    ///   - coordinates: An array of ``Coordinate`` values for which the elevation gain should be calculated
    ///   - threshold: The elevation threshold in meters to be applied.
    /// - Returns: The elevation gain
    func calculateElevationGain(threshold: Double = 5) -> Double {
        guard self.count > 1, let first = self.first else { return 0 }

        var reducedCoordinates: [Coordinate] = [first]
        var lastCoord = first

        for coordinate in self.dropFirst() where abs(coordinate.elevation - lastCoord.elevation) > threshold {
            reducedCoordinates.append(coordinate)
            lastCoord = coordinate
        }

        let zippedCoords = zip(reducedCoordinates, reducedCoordinates.dropFirst())
        return zippedCoords.reduce(0.0) { elevation, pair in
            let delta = pair.1.elevation - pair.0.elevation
            if delta > 0 {
                return elevation + delta
            }
            return elevation
        }
    }
}

private extension Array where Element == DistanceHeight {
    func calculateGradeSegments(_ segmentation: ElevationSmoothing) -> [GradeSegment] {
        switch segmentation {
        case .segmentation(let length):
            return calculateGradeSegments(segmentLength: length)
        case .smoothing(let smoothingValue):
            return calculateGradeSegments(smoothingValue)
        }
    }

    func calculateGradeSegments(segmentLength: Double) -> [GradeSegment] {
        guard !isEmpty else { return [] }

        let trackDistance = self[endIndex - 1].distance
        guard trackDistance >= segmentLength else {
            if let prevHeight = height(at: 0), let currentHeight = height(at: trackDistance) {
                return [.init(start: 0, end: trackDistance, grade: (currentHeight - prevHeight) / trackDistance, elevationAtStart: prevHeight)]
            }
            return []
        }
        var gradeSegments: [GradeSegment] = []
        var previousHeight: Double = self[0].elevation
        for distance in stride(from: segmentLength, to: trackDistance, by: segmentLength) {
            guard let height = height(at: distance) else { break }
            gradeSegments.append(.init(start: distance - segmentLength, end: distance, grade: (height - previousHeight) / segmentLength, elevationAtStart: previousHeight))
            previousHeight = height
        }
        if let last = gradeSegments.last,
           last.end < trackDistance {
            if let prevHeight = height(at: last.end), let currentHeight = height(at: trackDistance) {
                gradeSegments.append(.init(start: last.end, end: trackDistance, grade: (currentHeight - prevHeight) / (trackDistance - last.end), elevationAtStart: prevHeight))
            }
        }
        return gradeSegments.reduce(into: []) { joined, segment in
            guard let last = joined.last else {
                joined.append(segment)
                return
            }
            if (last.grade - segment.grade).magnitude > 0.003 {
                joined.append(segment)
            } else {
                let remaining = Swift.min(segmentLength, trackDistance - last.end)
                joined[joined.count - 1].end += remaining
            }
        }
    }

    func calculateGradeSegments(_ smoothingValue: Int) -> [GradeSegment] {
        guard !isEmpty else { return [] }

        var updateHeightMap: [DistanceHeight] = []
        for idx in self.indices {
            let start = (idx - smoothingValue / 2)
            let end = idx + smoothingValue / 2
            let r = (start...end).clamped(to: startIndex...(endIndex-1))
            var elevation = self[r].reduce(Double(self[idx].elevation)) { ele, distanceHeight in
                ele + distanceHeight.elevation
            }
            elevation /= Double(r.count)

            updateHeightMap.append(.init(distance: self[idx].distance, elevation: elevation))
        }
        let result = zip(updateHeightMap, updateHeightMap.dropFirst()).map { cur, next in
            return GradeSegment(start: cur.distance, end: next.distance, grade: (next.elevation - cur.elevation) / (next.distance - cur.distance), elevationAtStart: cur.elevation)
        }
        return result
    }

    func height(at distance: Double) -> Double? {
        if distance == 0 {
            return first?.elevation
        }
        if distance == last?.distance {
            return last?.elevation
        }
        guard let next = firstIndex(where: { element in
            element.distance > distance
        }), next > 0 else { return nil }

        let start = next - 1
        let delta = self[next].distance - self[start].distance
        let t = (distance - self[start].distance) / delta
        return linearInterpolated(start: self[start].elevation, end: self[next].elevation, using: t)
    }

    func linearInterpolated<Value: FloatingPoint>(start: Value, end: Value, using t: Value) -> Value {
        start + t * (end - start)
    }
}
