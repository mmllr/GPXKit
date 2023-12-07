import XCTest
import GPXKit
import CustomDump

final class GradeSegmentTests: XCTestCase {
    func testValidGrades() throws {
        try stride(from: -0.3, through: 0.3, by: 0.01).forEach { grade in
            let start = Double.random(in: 0...1000)
            let segment = try XCTUnwrap(GradeSegment(start: start, end: start + 10, grade: grade))
            XCTAssertEqual(grade, segment.grade, accuracy: 0.01)

            XCTAssertNotNil(try XCTUnwrap(GradeSegment(start: start, end: start + 10, elevationAtStart: start, elevationAtEnd: start + grade * 0.99)))
            XCTAssertNotNil(try XCTUnwrap(GradeSegment(start: start, end: start + 10, elevationAtStart: start, elevationAtEnd: start - grade * 0.99)))
        }
    }

    func testItIsNotPossibleToCreateSegmentsWithGradesGreaterThanThirtyPercent() throws {
        let start = Double.random(in: 0...1000)
        XCTAssertNil(GradeSegment(start: start, end: start + 10, grade: 0.31))
        XCTAssertNil(GradeSegment(start: start, end: start + 10, grade: -0.31))

        XCTAssertNil(GradeSegment(start: start, end: start + 100, elevationAtStart: start, elevationAtEnd: start + Double.random(in: 31...100)))
        XCTAssertNil(GradeSegment(start: start, end: start + 100, elevationAtStart: start, elevationAtEnd: start - Double.random(in: 31...100)))
    }

    func testItIsNotPossibleToCreateSegmentsWithGainGraterThanLength() throws {
        let length = Double.random(in: 10...100)
        let gain = Double.random(in: 10...100)

        XCTAssertNil(GradeSegment(start: 0, end: min(length, gain), elevationAtStart: 0, elevationAtEnd: max(length, gain)))
        XCTAssertNil(GradeSegment(start: 0, end: min(length, gain), elevationAtStart: 0, elevationAtEnd: -max(length, gain)))
    }
}
