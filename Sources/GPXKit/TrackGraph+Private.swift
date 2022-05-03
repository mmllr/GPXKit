import Foundation

extension TrackGraph {
    func findClimbs(epsilon: Double, minimumGrade: Double, maxJoinDistance: Double) -> [Climb] {
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

protocol Simplifiable {
    var x: Double { get }
    var y: Double { get }
}

extension DistanceHeight: Simplifiable {
    var x: Double { distance }
    var y: Double { elevation }
}

extension Coordinate: Simplifiable {
    var x: Double { latitude }
    var y: Double { longitude }
}

// MARK: - Private implementation -

fileprivate extension Simplifiable {
    func squaredDistanceToSegment(_ p1: Self, _ p2: Self) -> Double {
        var x = p1.x
        var y = p1.y
        var dx = p2.x - x
        var dy = p2.y - y

        if dx != 0 || dy != 0 {
            let deltaSquared = (dx * dx + dy * dy)
            let t = ((self.x - p1.x) * dx + (self.y - p1.y) * dy) / deltaSquared
            if t > 1 {
                x = p2.x
                y = p2.y
            } else if t > 0 {
                x += dx * t
                y += dy * t
            }
        }

        dx = self.x - x
        dy = self.y - y

        return dx * dx + dy * dy
    }
}

extension Array where Element: Simplifiable {
    func simplify(tolerance: Double) -> Self {
        return simplifyDouglasPeucker(self, sqTolerance: tolerance * tolerance)
    }

    private func simplifyDPStep(_ points: Self, first: Self.Index, last: Self.Index, sqTolerance: Double, simplified: inout Self) {
        guard last > first else {
            return
        }
        var maxSqDistance = sqTolerance
        var index = startIndex

        for currentIndex: Self.Index in first+1..<last {
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
