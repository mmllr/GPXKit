import Foundation

public protocol GeoCoordinate {
    var latitude: Double { get}
    var longitude: Double { get }
}

public struct Coordinate: Equatable, Hashable, GeoCoordinate {
    public var latitude: Double
    public var longitude: Double
    public var elevation: Double = 0

    public init(latitude: Double, longitude: Double, elevation: Double = 0) {
        self.latitude = latitude
        self.longitude = longitude
        self.elevation = elevation
    }
}

public struct TrackSegment: Hashable {
    public var coordinate: Coordinate
    public var distanceInMeters: Double

    public init(coordinate: Coordinate, distanceInMeters: Double) {
        self.coordinate = coordinate
        self.distanceInMeters = distanceInMeters
    }
}

public struct TrackPoint: Hashable {
    public var coordinate: Coordinate
    public var date: Date?
    public var power: Measurement<UnitPower>?

    public init(coordinate: Coordinate, date: Date? = nil, power: Measurement<UnitPower>? = nil) {
        self.coordinate = coordinate
        self.date = date
        self.power = power
    }
}

public struct TrackGraph: Equatable {
    public var segments: [TrackSegment]
    public var distance: Double
    public var elevationGain: Double
    public var heightMap: [DistanceHeight]

    public init(segments: [TrackSegment], distance: Double, elevationGain: Double, heightMap: [DistanceHeight]) {
        self.segments = segments
        self.distance = distance
        self.elevationGain = elevationGain
        self.heightMap = heightMap
    }
}

public struct DistanceHeight: Hashable {
    public var distance: Double
    public var elevation: Double

    public init(distance: Double, elevation: Double) {
        self.distance = distance
        self.elevation = elevation
    }
}

public struct GeoBounds: Hashable, Codable {
    public var minLatitude: Double
    public var minLongitude: Double
    public var maxLatitude: Double
    public var maxLongitude: Double

    public init(minLatitude: Double, minLongitude: Double, maxLatitude: Double, maxLongitude: Double) {
        self.minLatitude = minLatitude
        self.minLongitude = minLongitude
        self.maxLatitude = maxLatitude
        self.maxLongitude = maxLongitude
    }
}

public struct GPXTrack: Equatable {
    public var date: Date?
    public var title: String
    public var trackPoints: [TrackPoint]
    public var graph: TrackGraph
    public var bounds: GeoBounds

    public init(date: Date? = nil, title: String, trackPoints: [TrackPoint]) {
        self.date = date
        self.title = title
        self.trackPoints = trackPoints
        self.graph = TrackGraph(points: trackPoints)
        self.bounds = trackPoints.bounds()
    }
}
