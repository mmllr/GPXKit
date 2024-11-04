// MIT License
//
// Copyright © 2024 Markus Müller. All rights reserved.
//

import CustomDump
import Foundation
import GPXKit
import Numerics
import Testing

@Suite
struct ArrayExtensionsTests {
    @Test
    func testRemovingNearbyCoordinatesInEmptyCollection() {
        let coords: [Coordinate] = []

        expectNoDifference([], coords.removeIf(closerThan: 1))
    }

    @Test
    func testRemovingNearbyCoordinatesWithOneElement() {
        let coords: [Coordinate] = [.leipzig]

        expectNoDifference([.leipzig], coords.removeIf(closerThan: 1))
    }

    @Test
    func testRemovingNearbyCoordinatesWithTwoElement() {
        let coords: [Coordinate] = [.leipzig, .dehner]

        expectNoDifference([.leipzig, .dehner], coords.removeIf(closerThan: 1))
    }

    @Test
    func testRemovingDuplicateCoordinates() {
        let start = Coordinate.leipzig
        let coords: [Coordinate] = [
            start,
            start.offset(east: 60),
            start.offset(east: 100),
            start.offset(north: 120),
            start.offset(north: 160),
            .postPlatz
        ]

        let result = coords.removeIf(closerThan: 50)
        expectNoDifference([coords[0], coords[1], coords[3], .postPlatz], result)
    }

    @Test
    func testSmoothingElevation() {
        let start = Coordinate.leipzig.offset(elevation: 200)
        let coords: [Coordinate] = stride(from: 0, to: 100, by: 1).map { idx in
            start.offset(
                north: Double.random(in: 100 ... 1000),
                east: Double.random(in: 100 ... 1000),
                elevation: Double.random(in: idx.isMultiple(of: 10) ? 500 ... 550 : 100 ... 110)
            )
        }

        let avg = coords.map(\.elevation).reduce(0, +) / Double(coords.count)

        for (idx, coord) in coords.smoothedElevation(sampleCount: 50).enumerated() {
            assertGeoCoordinateEqual(coord, coords[idx])
            #expect(avg.isApproximatelyEqual(to: coord.elevation, absoluteTolerance: 15))
        }
    }

    @Test
    func testFlatteningGradeSegments() throws {
        let grades: [GradeSegment] = try [
            #require(.init(start: 0, end: 100, elevationAtStart: 50, elevationAtEnd: 60)),
            #require(.init(start: 100, end: 200, elevationAtStart: 60, elevationAtEnd: 75)),
            #require(GradeSegment(start: 200, end: 270, elevationAtStart: 75, elevationAtEnd: 82))
        ]

        #expect(grades[0].grade.isApproximatelyEqual(to: 0.1, absoluteTolerance: 0.001))
        #expect(grades[1].grade.isApproximatelyEqual(to: 0.15, absoluteTolerance: 0.01))
        #expect(grades[2].grade.isApproximatelyEqual(to: 0.1, absoluteTolerance: 0.001))

        let second = try #require(grades[1].adjusted(grade: grades[0].grade + 0.01))
        #expect(0.11.isApproximatelyEqual(to: second.grade, absoluteTolerance: 0.001))
        let third = try #require(GradeSegment(
            start: 200,
            end: 270,
            grade: second.grade - 0.01,
            elevationAtStart: second.elevationAtEnd
        ))
        #expect(0.1.isApproximatelyEqual(to: third.grade, absoluteTolerance: 0.001))

        let expected: [GradeSegment] = [
            grades[0],
            second,
            third
        ]
        let actual = try #require(try grades.flatten(maxDelta: 0.01))
        expectNoDifference(expected, actual)
    }

    @Test
    func testFlatteningGradeSegmentsWithVeryLargeGradeDifferencesDoesNotResultInNotANumber() throws {
        let track = try GPXFileParser(xmlString: .saCalobra).parse().get()

        let graph = TrackGraph(coords: .init(track.trackPoints.map(\.coordinate).prefix(50)))
        let actual = try #require(try graph.gradeSegments.flatten(maxDelta: 0.01))

        expectNoDifference(0, actual.filter { $0.grade.isNaN }.count)
    }

    @Test
    func testSmoothingElevationOnSmallCollections() {
        let start = Coordinate.leipzig.offset(elevation: 200)
        let end = start.offset(
            north: Double.random(in: 100 ... 1000),
            east: Double.random(in: 100 ... 1000),
            elevation: Double.random(in: 500 ... 550)
        )

        expectNoDifference([], [Coordinate]().smoothedElevation(sampleCount: Int.random(in: 2 ... 200)))
        expectNoDifference([start], [start].smoothedElevation(sampleCount: Int.random(in: 5 ... 200)))

        let coords: [Coordinate] = [start, end]
        let avg = coords.map(\.elevation).reduce(0, +) / Double(coords.count)

        expectNoDifference(
            [.init(latitude: start.latitude, longitude: start.longitude, elevation: avg), .init(
                latitude: end.latitude,
                longitude: end.longitude,
                elevation: avg
            )],
            coords.smoothedElevation(sampleCount: 50)
        )
    }
}
