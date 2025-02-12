//
// GPXKit - MIT License - Copyright © 2024 Markus Müller. All rights reserved.
//

import Foundation

/// A value describing a grade of a track. A ``TrackGraph`` has an array of ``GradeSegment`` from start to its distance
/// each with a given length and the grade at this distance.
public struct GradeSegment: Codable, Sendable {
    /// The start in meters of the segment.
    public var start: Double
    /// The end in meters of the grade segment.
    public var end: Double

    /// The elevation in meters at the start of the segment. Defaults to zero.
    public var elevationAtStart: Double

    // The elevation in meters at the end of the segment. Defaults to zero.
    public var elevationAtEnd: Double

    public init?(start: Double, end: Double, elevationAtStart: Double = 0, elevationAtEnd: Double = 0) {
        guard
            start < end,
            (end - start) * 0.3 >= abs(elevationAtEnd - elevationAtStart)
        else { return nil }
        self.start = start
        self.end = end
        self.elevationAtStart = elevationAtStart
        self.elevationAtEnd = elevationAtEnd
    }
}

extension GradeSegment: Equatable {
    public static func == (lhs: GradeSegment, rhs: GradeSegment) -> Bool {
        if lhs.start != rhs.start {
            return false
        }
        if lhs.end != rhs.end {
            return false
        }
        if abs(lhs.elevationAtStart - rhs.elevationAtStart) > 0.1 {
            return false
        }

        if abs(lhs.elevationAtEnd - rhs.elevationAtEnd) > 0.1 {
            return false
        }
        return true
    }
}

extension GradeSegment: Hashable {}

extension ClosedRange<Double> {
    static let allowedGrades: Self = -0.30 ... 0.3
}

public extension GradeSegment {
    struct InvalidGradeError: Error {}

    init?(start: Double, end: Double, grade: Double, elevationAtStart: Double = 0) {
        guard ClosedRange.allowedGrades.contains(grade) else { return nil }
        self.init(
            start: start,
            end: end,
            elevationAtStart: elevationAtStart,
            elevationAtEnd: elevationAtStart + atan(grade) * (end - start)
        )
    }

    /// The normalized grade in percent in the range -1...1.
    var grade: Double {
        guard length > .zero else { return .zero }
        // the length is the hypothenuse of the elevation triangle, see
        // https://theclimbingcyclist.com/gradients-and-cycling-an-introduction for more details
        // grade = gain / horizontal length
        let a = (pow(length, 2) - pow(elevationGain, 2)).squareRoot()
        return elevationGain / a
    }

    /// The length in meters of the segment.
    var length: Double {
        end - start
    }

    /// The elevation gain  in meters of the segment.
    var elevationGain: Double {
        elevationAtEnd - elevationAtStart
    }

    mutating func adjust(grade: Double) throws {
        guard let new = adjusted(grade: grade) else { throw InvalidGradeError() }
        self = new
    }

    func adjusted(grade: Double) -> Self? {
        return .init(
            start: start,
            end: end,
            elevationAtStart: elevationAtStart,
            elevationAtEnd: elevationAtStart + atan(grade) * length
        )
    }

    mutating func merge(_ other: Self) {
        guard (grade - other.grade).magnitude < 0.003 else { return }
        end = other.end
        elevationAtEnd = other.elevationAtEnd
    }
}
