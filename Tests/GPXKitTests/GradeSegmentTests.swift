//
// GPXKit - MIT License - Copyright © 2024 Markus Müller. All rights reserved.
//

import CustomDump
import GPXKit
import Numerics
import Testing

struct GradeSegmentTests {
    @Test
    func testValidGrades() throws {
        try stride(from: -0.3, through: 0.3, by: 0.01).forEach { grade in
            let start = Double.random(in: 0 ... 1000)
            let segment = try #require(GradeSegment(start: start, end: start + 10, grade: grade))
            #expect(grade.isApproximatelyEqual(to: segment.grade, absoluteTolerance: 0.01))

            _ = try #require(GradeSegment(start: start, end: start + 10, elevationAtStart: start, elevationAtEnd: start + grade * 0.99))
            _ = try #require(GradeSegment(start: start, end: start + 10, elevationAtStart: start, elevationAtEnd: start - grade * 0.99))
        }
    }

    @Test
    func testItIsNotPossibleToCreateSegmentsWithGradesGreaterThanThirtyPercent() throws {
        let start = Double.random(in: 0 ... 1000)
        #expect(GradeSegment(start: start, end: start + 10, grade: 0.31) == nil)
        #expect(GradeSegment(start: start, end: start + 10, grade: -0.31) == nil)

        #expect(GradeSegment(
            start: start,
            end: start + 100,
            elevationAtStart: start,
            elevationAtEnd: start + Double.random(in: 31 ... 100)
        ) == nil)
        #expect(GradeSegment(
            start: start,
            end: start + 100,
            elevationAtStart: start,
            elevationAtEnd: start - Double.random(in: 31 ... 100)
        ) == nil)
    }

    @Test
    func testItIsNotPossibleToCreateSegmentsWithGainGraterThanLength() throws {
        let length = Double.random(in: 10 ... 100)
        let gain = Double.random(in: 10 ... 100)

        #expect(GradeSegment(start: 0, end: min(length, gain), elevationAtStart: 0, elevationAtEnd: max(length, gain)) == nil)
        #expect(GradeSegment(start: 0, end: min(length, gain), elevationAtStart: 0, elevationAtEnd: -max(length, gain)) == nil)
    }
}
