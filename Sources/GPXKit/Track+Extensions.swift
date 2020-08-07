import Foundation

public extension Coordinate {
    func distance(to: Coordinate) -> Double {
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
