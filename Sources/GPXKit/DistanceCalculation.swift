// swiftlint:disable identifier_name
// swiftlint:disable function_body_length

import Foundation

extension FloatingPoint {
    var degreesToRadians: Self { self * .pi / 180 }
    var radiansToDegrees: Self { self * 180 / .pi }
}

/// Error indicating that the distance could not be computed within the maximal number of iterations.
public enum ConvergenceError: Error, Sendable {
    case notConverged(maxIter: UInt, tol: Double, eps: Double)
}

/// [WGS 84 ellipsoid](https://en.wikipedia.org/wiki/World_Geodetic_System) definition
public let wgs84 = (a: 6_378_137.0, f: 1 / 298.257223563)

/// π (for convenience)
private let pi = Double.pi

extension GeoCoordinate {
    ///
    /// Compute the distance between two points on an ellipsoid.
    ///
    /// - Parameters:
    ///   - x: first point with latitude and longitude in radiant.
    ///   - y: second point with latitude and longitude in radiant.
    ///   - tol: tolerance for the computed distance (in meters)
    ///   - maxIter: maximal number of iterations
    ///   - a: first ellipsoid parameter in meters (defaults to WGS-84 parameter)
    ///   - f: second ellipsoid parameter in meters (defaults to WGS-84 parameter)
    ///
    /// - Returns: distance between `x` and `y` in meters.
    ///
    /// - Throws:
    ///   - `ConvergenceError.notConverged` if the distance computation does not converge within `maxIter` iterations.
    ///
    /// The ellipsoid parameters default to the WGS-84 parameters.
    /// [Details](https://www.movable-type.co.uk/scripts/latlong-vincenty.html).
    /// [Sample implementation in Swift](https://github.com/dastrobu/vincenty/blob/master/Sources/vincenty/vincenty.swift).
    public func distanceVincenty(to: GeoCoordinate,
                                 tol: Double = 1e-12,
                                 maxIter: UInt = 200,
                                 ellipsoid: (a: Double, f: Double) = wgs84) throws -> Double {
        assert(tol > 0, "tol '\(tol)' ≤ 0")

        // validate lat and lon values
        assert(latitude.degreesToRadians >= -pi / 2 && latitude.degreesToRadians <= pi / 2, "latitude '\(latitude.degreesToRadians)' outside [-π/2, π]")
        assert(to.latitude.degreesToRadians >= -pi / 2 && to.latitude.degreesToRadians <= pi / 2, "to.latitude '\(to.latitude.degreesToRadians)' outside [-π/2, π]")
        assert(longitude.degreesToRadians >= -pi && longitude.degreesToRadians <= pi, "longitude '\(to.longitude.degreesToRadians)' outside [-π, π]")
        assert(to.longitude.degreesToRadians >= -pi && to.longitude.degreesToRadians <= pi, "to.longitude '\(to.longitude.degreesToRadians)' outside [-π, π]")

        // shortcut for zero distance
        if self.latitude == to.latitude &&
            self.longitude == to.longitude {
            return 0.0
        }

        // compute ellipsoid constants
        let A: Double = ellipsoid.a
        let F: Double = ellipsoid.f
        let B: Double = (1 - F) * A
        let C: Double = (A * A - B * B) / (B * B)

        let u_x: Double = atan((1 - F) * tan(latitude.degreesToRadians))
        let sin_u_x: Double = sin(u_x)
        let cos_u_x: Double = cos(u_x)

        let u_y: Double = atan((1 - F) * tan(to.latitude.degreesToRadians))
        let sin_u_y: Double = sin(u_y)
        let cos_u_y: Double = cos(u_y)

        let l: Double = to.longitude.degreesToRadians - longitude.degreesToRadians

        var lambda: Double = l, tmp: Double = 0.0
        var q: Double = 0.0, p: Double = 0.0, sigma: Double = 0.0, sin_alpha: Double = 0.0, cos2_alpha: Double = 0.0
        var c: Double = 0.0, sin_sigma: Double = 0.0, cos_sigma: Double = 0.0, cos_2sigma: Double = 0.0

        for _ in 0 ..< maxIter {
            tmp = cos(lambda)
            q = cos_u_y * sin(lambda)
            p = cos_u_x * sin_u_y - sin_u_x * cos_u_y * tmp
            sin_sigma = sqrt(q * q + p * p)
            cos_sigma = sin_u_x * sin_u_y + cos_u_x * cos_u_y * tmp
            sigma = atan2(sin_sigma, cos_sigma)

            // catch zero division problem
            if sin_sigma == 0.0 {
                sin_sigma = Double.leastNonzeroMagnitude
            }

            sin_alpha = (cos_u_x * cos_u_y * sin(lambda)) / sin_sigma
            cos2_alpha = 1 - sin_alpha * sin_alpha
            cos_2sigma = cos_sigma - (2 * sin_u_x * sin_u_y) / cos2_alpha

            // check for nan
            if cos_2sigma.isNaN {
                cos_2sigma = 0.0
            }

            c = F / 16.0 * cos2_alpha * (4 + F * (4 - 3 * cos2_alpha))
            tmp = lambda
            lambda = (l + (1 - c) * F * sin_alpha
                        * (sigma + c * sin_sigma
                            * (cos_2sigma + c * cos_sigma
                                * (-1 + 2 * cos_2sigma * cos_2sigma
                                )))
            )

            if fabs(lambda - tmp) < tol {
                break
            }
        }
        let eps: Double = fabs(lambda - tmp)
        if eps >= tol {
            throw ConvergenceError.notConverged(maxIter: maxIter, tol: tol, eps: eps)
        }

        let uu: Double = cos2_alpha * C
        let a: Double = 1 + uu / 16384 * (4096 + uu * (-768 + uu * (320 - 175 * uu)))
        let b: Double = uu / 1024 * (256 + uu * (-128 + uu * (74 - 47 * uu)))
        let delta_sigma: Double = (b * sin_sigma
                                    * (cos_2sigma + 1.0 / 4.0 * b
                                        * (cos_sigma * (-1 + 2 * cos_2sigma * cos_2sigma)
                                            - 1.0 / 6.0 * b * cos_2sigma
                                            * (-3 + 4 * sin_sigma * sin_sigma)
                                            * (-3 + 4 * cos_2sigma * cos_2sigma))))

        return B * a * (sigma - delta_sigma)
    }

    /// Calculates the distance in meters to a coordinate using the **haversine** formula.
    /// - Parameter to: The coordinate to which the distance should be calculated.
    /// - Returns: Distance in meters
    ///
    /// [Details](https://www.movable-type.co.uk/scripts/latlong.html)
    func calculateHaversineDistance(to: GeoCoordinate) -> Double {
        let R = 6371e3 // metres
        let φ1 = latitude.degreesToRadians
        let φ2 = to.latitude.degreesToRadians
        let Δφ = (to.latitude - latitude).degreesToRadians
        let Δλ = (to.longitude - longitude).degreesToRadians

        let a = sin(Δφ / 2) * sin(Δφ / 2) +
            cos(φ1) * cos(φ2) *
            sin(Δλ / 2) * sin(Δλ / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        let d = R * c
        return d
    }

    /// Calculates the radius in meters around a coordinate for a latitude delta.
    ///
    /// One degree of latitude is always approximately 111 kilometers (69 miles). So the radius can derived from the delta (the coordinates latitude minus latitudeDelta/2).
    /// - Parameter latitudeDelta: The latitude delta.
    /// - Returns: The radius in meters.
    public func radiusInMeters(latitudeDelta: Double) -> Double {
        let topCentralLat: Double = latitude - latitudeDelta / 2
        let topCentralLocation = Coordinate(latitude: topCentralLat, longitude: longitude, elevation: 0)
        return distance(to: topCentralLocation)
    }

    /// Calculates the `GeoBounds` for a `GeoCoordinate` around a given radius in meters.
    ///
    /// [Details on Jan Philip Matuscheks website](http://janmatuschek.de/LatitudeLongitudeBoundingCoordinates#Latitude)
    /// - Parameter distanceInMeters: Distance in meters around the coordinate.
    /// - Returns: A `GeoBounds` value or nil if no bounds could be calculated (if distanceInMeters is below zero).
    public func bounds(distanceInMeters: Double) -> GeoBounds? {
        guard distanceInMeters >= 0.0 else { return nil }

        // angular distance is radians on a great circle
        let earthRadius = 6_378_137.0 // meters
        let radDist = distanceInMeters / earthRadius
        let radLatitude = latitude.degreesToRadians
        let radLongitude = longitude.degreesToRadians

        let MinLatitude = -90.degreesToRadians // -PI/2
        let MaxLatitude = 90.degreesToRadians  // PI/2
        let MinLongitude = -180.degreesToRadians   // -PI
        let MaxLongitude = 180.degreesToRadians    // PI

        var minLat: Double = radLatitude - radDist
        var maxLat: Double = radLatitude + radDist

        var minLon: Double, maxLon: Double

        if minLat > MinLatitude && maxLat < MaxLatitude {
            let deltaLon = asin(sin(radDist) / cos(radLatitude))
            minLon = radLongitude - deltaLon

            if minLon < MinLongitude { minLon += 2 * .pi }
            maxLon = radLongitude + deltaLon
            if maxLon > MaxLongitude { maxLon -= 2 * .pi }
        }
        else {
            minLat = max(minLat, MinLatitude)
            maxLat = min(maxLat, MaxLatitude)
            minLon = MinLongitude
            maxLon = MaxLongitude
        }

        return GeoBounds(
            minLatitude: minLat.radiansToDegrees,
            minLongitude: minLon.radiansToDegrees,
            maxLatitude: maxLat.radiansToDegrees,
            maxLongitude: maxLon.radiansToDegrees
        )
    }
}
