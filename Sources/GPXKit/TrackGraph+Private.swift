//
//  File.swift
//  File
//
//  Created by Markus Müller on 24.08.21.
//

import Foundation

extension TrackGraph {
    func findClimps(epsilon: Double, minimumGrade: Double, maxJoinDistance: Double) -> [Climb] {
        let simplified = heightMap.simplify(tolerance: epsilon)
        let climbs: [Climb] = zip(simplified, simplified.dropFirst()).compactMap { start, end in
            guard end.elevation > start.elevation else { return nil }
            let elevation = end.elevation - start.elevation
            let distance = end.distance - start.distance
            let grade = elevation / distance
            guard grade >= minimumGrade else { return nil }
            return Climb(
                start: start.distance,
                end: end.distance,
                bottom: start.elevation,
                top: end.elevation,
                totalElevation: end.elevation - start.elevation,
                grade: grade,
                maxGrade: grade,
                score: (elevation * elevation) / (distance * 10)
            )
        }
        return join(climbs: climbs, maxJoinDistance: maxJoinDistance)
    }

    fileprivate func join(climbs: [Climb], maxJoinDistance: Double) -> [Climb] {
        return climbs.reduce(into: []) { joinedClimbs, climb in
            guard let last = joinedClimbs.last else {
                joinedClimbs.append(climb)
                return
            }
            if (climb.start - last.end) <= maxJoinDistance.magnitude {
                let distance = climb.end - last.start
                let totalElevation = last.totalElevation + climb.totalElevation
                let joined = Climb(
                    start: last.start,
                    end: climb.end,
                    bottom: last.bottom,
                    top: climb.top,
                    totalElevation: totalElevation,
                    grade: totalElevation / distance,
                    maxGrade: max(last.maxGrade, climb.maxGrade),
                    score: last.score + climb.score
                )
                joinedClimbs[joinedClimbs.count - 1] = joined
            } else {
                joinedClimbs.append(climb)
            }
        }
    }
}

// MARK: - Private implementation -

fileprivate extension DistanceHeight {
    func squaredDistanceToSegment(_ p1: Self, _ p2: Self) -> Double {
        var x = p1.distance
        var y = p1.elevation
        var dx = p2.distance - x
        var dy = p2.elevation - y

        if dx != 0 || dy != 0 {
            let deltaSquared = (dx * dx + dy * dy)
            let t = ((distance - p1.distance) * dx + (elevation - p1.elevation) * dy) / deltaSquared
            if t > 1 {
                x = p2.distance
                y = p2.elevation
            } else if t > 0 {
                x += dx * t
                y += dy * t
            }
        }

        dx = distance - x
        dy = elevation - y

        return dx * dx + dy * dy
    }
}

fileprivate extension Array where Element == DistanceHeight {
    func simplify(tolerance: Double) -> [Element] {
        return simplifyDouglasPeucker(self, sqTolerance: tolerance * tolerance)
    }

    private func simplifyDPStep(_ points: [Element], first: Int, last: Int, sqTolerance: Double, simplified: inout [Element]) {
        guard last > first else {
            return
        }
        var maxSqDistance = sqTolerance
        var index = 0

        for currentIndex in first+1..<last {
            let sqDistance = points[currentIndex].squaredDistanceToSegment(points[first], points[last])
            if sqDistance > maxSqDistance {
                maxSqDistance = sqDistance
                index = currentIndex
            }
        }

        if maxSqDistance > sqTolerance {
            if (index - first) > 1 {
                simplifyDPStep(points, first: first, last: index, sqTolerance: sqTolerance, simplified: &simplified)
            }
            simplified.append(points[index])
            if (last - index) > 1 {
                simplifyDPStep(points, first: index, last: last, sqTolerance: sqTolerance, simplified: &simplified)
            }
        }
    }

    private func simplifyDouglasPeucker(_ points: [Element], sqTolerance: Double) -> [Element] {
        guard points.count > 1 else {
            return []
        }

        let last = (points.count - 1)
        var simplied = [points.first!]
        simplifyDPStep(points, first: 0, last: last, sqTolerance: sqTolerance, simplified: &simplied)
        simplied.append(points.last!)

        return simplied
    }
}
