import Foundation

public protocol GeoCoordinate {
    var latitude: Double { get}
    var longitude: Double { get }
}

public struct Coordinate: Equatable, Hashable, GeoCoordinate {
    public var latitude: Double
    public var longitude: Double
    public var elevation: Double
}

public struct TrackSegment: Equatable {
    public var coordinate: Coordinate
    public var distanceInMeters: Double
}

public struct TrackPoint: Equatable, Hashable {
    public var coordinate: Coordinate
    public var date: Date?
    public var power: Measurement<UnitPower>?
}

public struct TrackGraph: Equatable {
    public var segments: [TrackSegment]
    public var distance: Double
    public var elevationGain: Double
}

public struct GPXTrack: Equatable {
    public var date: Date?
    public var title: String
    public var trackPoints: [TrackPoint]
}
