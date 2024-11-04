//
// GPXKit - MIT License - Copyright © 2024 Markus Müller. All rights reserved.
//

import Foundation

/// Value type describing a logical segment in a `TrackGraph`. A `TrackGraph` consists of a collection of `TrackSegment`s. Each has a
/// coordinate (latitude, longitude & elevation) and the distance (in meters) to its preceding segment point.
public struct TrackSegment: Hashable, Sendable {
    /// The ``Coordinate`` (latitude, longitude and elevation)
    public var coordinate: Coordinate

    /// Distance in meters to its preceding `TrackSegment` in a `TrackGraph`
    public var distanceInMeters: Double

    /// Initializes a `TrackSegment`
    /// You don't need to construct this value by yourself, as it is done by GXPKits track parsing logic.
    /// - Parameters:
    ///   - coordinate: A ``Coordinate`` struct, contains latitude/longitude and elevation
    ///   - distanceInMeters: Distance in meters to its preceding `TrackSegment` in a `TrackGraph`
    public init(coordinate: Coordinate, distanceInMeters: Double) {
        self.coordinate = coordinate
        self.distanceInMeters = distanceInMeters
    }
}

extension Collection where Element == TrackSegment {
    func calculateDistance() -> Double {
        reduce(0) { $0 + $1.distanceInMeters }
    }
}
