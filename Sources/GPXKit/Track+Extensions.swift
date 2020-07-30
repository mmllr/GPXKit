import Foundation

public extension Coordinate {
    func distance(to other: Coordinate) -> Double {
        let R = 6_371_000.0
        let dLat = (latitude - other.latitude) * .pi / 180.0
        let dLon = (longitude - other.longitude) * .pi / 180.0
        let lat1 = other.latitude * .pi / 180.0
        let lat2 = longitude * .pi / 180.0

        let a1 = sin(dLat / 2.0) * sin(dLat / 2.0)
        let a2 = sin(dLon / 2.0) * sin(dLon / 2.0) * cos(lat1) * cos(lat2)
        let a = a1 + a2
        let c = 2 * atan2(a.squareRoot(), (1 - a).squareRoot())
        let d = R * c
        return d
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
	}

	var heightMap: [(Int, Int)] {
		var distanceSoFar: Double = 0
		return segments.map {
			distanceSoFar += $0.distanceInMeters
			return (Int(distanceSoFar), Int($0.coordinate.elevation))
		}
	}
}

public extension GPXTrack {
	var graph: TrackGraph {
		TrackGraph(points: trackPoints)
	}
}
