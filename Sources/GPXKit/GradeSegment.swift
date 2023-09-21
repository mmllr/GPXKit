//
// Created by Markus Müller on 13.12.21.
//

import Foundation

/// A value describing a grade of a track. A `TrackGraph` has an array of `GradeSegment` from start to its distance each with a given lenght and the grade at this distance.
public struct GradeSegment: Sendable {
    /// The start in meters of the segment.
    public var start: Double
    /// The end in meters of the grade segment.
    public var end: Double
    /// The normalized grade in percent in the range -1...1.
    public var grade: Double

    public init(start: Double, end: Double, grade: Double) {
        self.start = start
        self.end = end
        self.grade = grade
    }
}

extension GradeSegment: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(start)
        hasher.combine(end)
        hasher.combine(grade)
    }

    public static func ==(lhs: GradeSegment, rhs: GradeSegment) -> Bool {
        if lhs.start != rhs.start {
            return false
        }
        if lhs.end != rhs.end {
            return false
        }
        if (lhs.grade - rhs.grade).magnitude > 0.0025 {
            return false
        }
        return true
    }
}
