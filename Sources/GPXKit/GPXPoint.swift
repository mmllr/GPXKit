import Foundation

/// A value describing a single data point in a `GPXTrack`. A `TrackPoint` has the latitude, longitude and elevation data along with meta data such as a timestamp or power values.
public struct GPXPoint: Hashable, Sendable {
    /// The ``Coordinate`` (latitude, longitude and elevation in meters)
    public var coordinate: Coordinate
    /// Optional date for a given point. This is the date stamp from a gpx file, recorded from a bicycle computer or running watch.
    public var date: Date?
    /// Optional power value for a given point in a gpx file, which got recorded from a bicycle computer through a power meter.
    public var power: Measurement<UnitPower>?
    /// Optional cadence value in revolutions per minute for a given point in a gpx file, which got recorded from a bicycle computer through a cadence sensor.
    public var cadence: UInt?
    /// Optional heartrate value in beats per minute for a given point in a gpx file, which got recorded from a bicycle computer through a heartrate sensor.
    public var heartrate: UInt?
    /// Optional temperature value for a given point in a gpx file, which got recorded from a bicycle computer through a temperature sensor.
    public var temperature: Measurement<UnitTemperature>?

    /// Initializer
    /// You don't need to construct this value by yourself, as it is done by GXPKits track parsing logic.
    /// - Parameters:
    ///   - coordinate: The ``Coordinate`` (latitude, longitude and elevation in meters)
    ///   - date: Optional date for a point. Defaults to nil.
    ///   - power: Optional power value for a point. Defaults to nil.
    ///   - cadence: Optional cadence value for a point. Defaults to nil.
    ///   - heartrate: Optional heartrate value for a point. Defaults to nil.
    ///   - temperature: Optional temperature value for a point. Defaults to nil.
    public init(coordinate: Coordinate, date: Date? = nil, power: Measurement<UnitPower>? = nil, cadence: UInt? = nil, heartrate: UInt? = nil, temperature: Measurement<UnitTemperature>? = nil) {
        self.coordinate = coordinate
        self.date = date
        self.power = power
        self.cadence = cadence
        self.heartrate = heartrate
        self.temperature = temperature
    }
}

extension GPXPoint: GeoCoordinate {
    public var latitude: Double { coordinate.latitude }
    public var longitude: Double { coordinate.longitude }
}
