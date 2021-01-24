import Foundation

public extension GeoCoordinate {
    func distance(to: GeoCoordinate) -> Double {
        guard let dist = try? distanceVincenty(to: to) else { return calculateSimpleDistance(to: to) }
        return dist
    }
}

public extension TrackGraph {
	init(coords: [Coordinate]) {
		let zippedCoords = zip(coords, coords.dropFirst())
		let distances: [Double] = [0.0] + zippedCoords.map {
			$0.distance(to: $1)
		}
		segments = zip(coords, distances).map {
			TrackSegment(coordinate: $0, distanceInMeters: $1)
		}
		distance = distances.reduce(0, +)
		elevationGain = zippedCoords.reduce(0.0) { elevation, pair in
			let delta = pair.1.elevation - pair.0.elevation
			if delta > 0 {
				return elevation + delta
			}
			return elevation
		}
        heightMap = segments.reduce((0.0, [DistanceHeight]())) { acc, segment in
            let distanceSoFar = acc.0 + segment.distanceInMeters
            let heightMap = acc.1 + [DistanceHeight(distance: distanceSoFar, elevation: segment.coordinate.elevation)]
            return (distanceSoFar, heightMap)
        }.1
	}
}

public extension TrackGraph {
    init(points: [TrackPoint]) {
        self.init(coords: points.map { $0.coordinate })
    }
}

public extension GPXFileParser {
    convenience init?(url: URL) {
        guard let xmlString = try? String(contentsOf: url) else { return nil }
        self.init(xmlString: xmlString)
    }

    convenience init?(data: Data) {
        guard let xmlString = String(data: data, encoding: .utf8) else { return nil }
        self.init(xmlString: xmlString)
    }
}
