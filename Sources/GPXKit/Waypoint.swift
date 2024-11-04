//
// GPXKit - MIT License - Copyright © 2024 Markus Müller. All rights reserved.
//

import Foundation

/// Value type describing a single Waypoint defined  within a `GPXTrack`. A `Waypoint` has a location consisting of latitude, longitude and
/// some metadata,
/// e.g. name and description.
public struct Waypoint: Hashable, Sendable {
    /// The ``Coordinate`` (latitude, longitude and elevation in meters)
    public var coordinate: Coordinate
    /// Optional date for a given point.
    public var date: Date?
    /// Optional name of the waypoint
    public var name: String?
    /// Optional comment for the waypoint
    public var comment: String?
    /// Optional description of the waypoint
    public var description: String?

    /// Initializer
    /// You don't need to construct this value by yourself, as it is done by GXPKits track parsing logic.
    /// - Parameters:
    ///   - coordinate: ``Coordinate`` of the waypoint, required
    ///   - date: Optional date
    ///   - name: Name of the waypoint
    ///   - comment: A short comment
    ///   - description: A longer description
    public init(coordinate: Coordinate, date: Date? = nil, name: String? = nil, comment: String? = nil, description: String? = nil) {
        self.coordinate = coordinate
        self.date = date
        self.name = name
        self.comment = comment
        self.description = description
    }
}
