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
