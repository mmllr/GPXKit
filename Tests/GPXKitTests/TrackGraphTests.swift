//
// GPXKit - MIT License - Copyright © 2024 Markus Müller. All rights reserved.
//

import CustomDump
import Foundation
import GPXKit
import Numerics
import Testing

@Suite
struct TrackGraphTests {
    let coordinates: [Coordinate] = [
        Coordinate(latitude: 51.2763320, longitude: 12.3767670, elevation: 82.2),
        Coordinate(latitude: 51.2763700, longitude: 12.3767550, elevation: 82.2),
        Coordinate(latitude: 51.2764100, longitude: 12.3767400, elevation: 82.2),
        Coordinate(latitude: 51.2764520, longitude: 12.3767260, elevation: 82.2),
        Coordinate(latitude: 51.2765020, longitude: 12.3767050, elevation: 82.2)
    ]

    func givenAPoint(latitude: Double, longitude: Double, elevation: Double) -> TrackPoint {
        return TrackPoint(
            coordinate: Coordinate(latitude: latitude, longitude: longitude, elevation: elevation),
            date: Date()
        )
    }

    func expectedDistance(from: Coordinate, to: Coordinate) -> Double {
        return from.distance(to: to)
    }

    func expectedGrade(for start: DistanceHeight, end: DistanceHeight) -> Double {
        expectedGrade(elevation: end.elevation - start.elevation, distance: end.distance - start.distance)
    }

    func expectedGrade(elevation: Double, distance: Double) -> Double {
        elevation / distance.magnitude
    }

    func expectedScore(start: DistanceHeight, end: DistanceHeight) -> Double {
        expectedScore(distance: end.distance - start.distance, height: end.elevation - start.elevation)
    }

    func expectedScore(distance: Double, height: Double) -> Double {
        // FIETS Score = (H * H / (D * 10)) + (T - 1000) / 1000 Note: The last part (+ (T - 1000) / 1000) will be
        // omitted
        return height * height / (distance * 10.0)
    }

    // MARK: Tests

    @Test
    func testSegmentDistances() throws {
        let expectedDistances = [0.0] + zip(coordinates, coordinates.dropFirst()).map {
            expectedDistance(from: $0, to: $1)
        }

        let sut = try TrackGraph(coords: coordinates, elevationSmoothing: .segmentation(50))
        for (index, expectedDistance) in expectedDistances.enumerated() {
            #expect(sut.segments[index].distanceInMeters.isApproximatelyEqual(to: expectedDistance, absoluteTolerance: 0.001))
        }
    }

    @Test
    func testTotalDistance() throws {
        let totalDistance = zip(coordinates, coordinates.dropFirst()).map {
            expectedDistance(from: $0, to: $1)
        }.reduce(0, +)

        let sut = try TrackGraph(coords: coordinates, elevationSmoothing: .segmentation(50))
        #expect(totalDistance.isApproximatelyEqual(to: sut.distance, absoluteTolerance: 0.001))
    }

    @Test
    func testTotalElevationWithTheSameElevationAtEveryPoint() throws {
        let coordinates: [Coordinate] = [
            Coordinate(latitude: 51.2763320, longitude: 12.3767670, elevation: 1),
            Coordinate(latitude: 51.2763700, longitude: 12.3767550, elevation: 1),
            Coordinate(latitude: 51.2764100, longitude: 12.3767400, elevation: 1),
            Coordinate(latitude: 51.2764520, longitude: 12.3767260, elevation: 1),
            Coordinate(latitude: 51.2765020, longitude: 12.3767050, elevation: 1)
        ]

        let sut = try TrackGraph(coords: coordinates, elevationSmoothing: .segmentation(50))

        expectNoDifference(0, sut.elevationGain)
    }

    @Test
    func testTotalElevationWithDifferentElevation() throws {
        let coordinates: [Coordinate] = [
            Coordinate(latitude: 51.2763320, longitude: 12.3767670, elevation: 1),
            Coordinate(latitude: 51.2763700, longitude: 12.3767550, elevation: 11), // 10
            Coordinate(latitude: 51.2764100, longitude: 12.3767400, elevation: 5), // -6
            Coordinate(latitude: 51.2764520, longitude: 12.3767260, elevation: 100), // 95
            Coordinate(latitude: 51.2765020, longitude: 12.3767050, elevation: 76), // -24
            Coordinate(latitude: 51.2765520, longitude: 12.3766820, elevation: 344) // 268
        ]

        let sut = try TrackGraph(coords: coordinates, elevationSmoothing: .segmentation(50))

        // 10 + 95 + 268
        expectNoDifference(373, sut.elevationGain)
    }

    @Test
    func testInitializationFromGPX() throws {
        let points: [TrackPoint] = [
            givenAPoint(latitude: 51.2763320, longitude: 12.3767670, elevation: 1),
            givenAPoint(latitude: 51.2763700, longitude: 12.3767550, elevation: 1),
            givenAPoint(latitude: 51.2764100, longitude: 12.3767400, elevation: 1),
            givenAPoint(latitude: 51.2764520, longitude: 12.3767260, elevation: 1),
            givenAPoint(latitude: 51.2765020, longitude: 12.3767050, elevation: 1)
        ]

        let sut = try TrackGraph(points: points)

        let expectedCoordinates: [Coordinate] = [
            Coordinate(latitude: 51.2763320, longitude: 12.3767670, elevation: 1),
            Coordinate(latitude: 51.2763700, longitude: 12.3767550, elevation: 1),
            Coordinate(latitude: 51.2764100, longitude: 12.3767400, elevation: 1),
            Coordinate(latitude: 51.2764520, longitude: 12.3767260, elevation: 1),
            Coordinate(latitude: 51.2765020, longitude: 12.3767050, elevation: 1)
        ]
        expectNoDifference(expectedCoordinates, sut.segments.map { $0.coordinate })
    }

    @Test
    func testTheInitialElevationIsSubstractedFromTheElevationGain() throws {
        let coordinates: [Coordinate] = [
            Coordinate(latitude: 51.2763320, longitude: 12.3767670, elevation: 100),
            Coordinate(latitude: 51.2763700, longitude: 12.3767550, elevation: 110),
            Coordinate(latitude: 51.2764100, longitude: 12.3767400, elevation: 120),
            Coordinate(latitude: 51.2764520, longitude: 12.3767260, elevation: 130),
            Coordinate(latitude: 51.2765020, longitude: 12.3767050, elevation: 140),
            Coordinate(latitude: 51.2765520, longitude: 12.3766820, elevation: 150)
        ]

        let sut = try TrackGraph(coords: coordinates, elevationSmoothing: .segmentation(50))

        // 10 + 95 + 268
        expectNoDifference(50, sut.elevationGain)
    }

    @Test
    func testElevationGainIsTheSumOfAllElevationDifferences() throws {
        let coordinates: [Coordinate] = [
            Coordinate(latitude: 51.2763320, longitude: 12.3767670, elevation: 100),
            Coordinate(latitude: 51.2763700, longitude: 12.3767550, elevation: 130), // 30
            Coordinate(latitude: 51.2764100, longitude: 12.3767400, elevation: 70),
            Coordinate(latitude: 51.2764520, longitude: 12.3767260, elevation: 150), // 80
            Coordinate(latitude: 51.2765020, longitude: 12.3767050, elevation: 140),
            Coordinate(latitude: 51.2765520, longitude: 12.3766820, elevation: 150) // 10
        ]

        let sut = try TrackGraph(coords: coordinates, elevationSmoothing: .segmentation(50))

        expectNoDifference(30 + 80 + 10, sut.elevationGain)
    }

    @Test
    func testEmptyTrackGraphHasNoClimbs() throws {
        let sut = try TrackGraph(coords: [], elevationSmoothing: .segmentation(50))

        expectNoDifference([], sut.climbs())
    }

    @Test
    func testClimbsWithOnePointInTrackIsEmpty() throws {
        let sut = try TrackGraph(coords: [.leipzig], elevationSmoothing: .segmentation(50))

        expectNoDifference([], sut.climbs())
    }

    @Test
    func testATrackWithTwoPointsHasOneClimb() throws {
        let sut = try TrackGraph(
            coords: [.leipzig, .leipzig.offset(east: 1000, elevation: 50)],
            elevationSmoothing: .segmentation(50)
        )

        let expected = Climb(
            start: sut.heightMap.first!.distance,
            end: sut.heightMap.last!.distance,
            bottom: sut.heightMap.first!.elevation,
            top: sut.heightMap.last!.elevation,
            totalElevation: sut.heightMap.last!.elevation - sut.heightMap.first!.elevation,
            grade: expectedGrade(for: sut.heightMap.first!, end: sut.heightMap.last!),
            maxGrade: expectedGrade(for: sut.heightMap.first!, end: sut.heightMap.last!),
            score: expectedScore(
                start: sut.heightMap.first!,
                end: sut.heightMap.last!
            )
        )

        expectNoDifference([expected], sut.climbs())
    }

    @Test
    func testDownhillSectionsWillNotBeInTheClimbs() throws {
        let sut = try TrackGraph(
            coords: [.leipzig, .leipzig.offset(north: 1000, elevation: -50)],
            elevationSmoothing: .segmentation(50)
        )

        expectNoDifference([], sut.climbs())
    }

    @Test
    func testMultipleAdjacentClimbSegmentsWithDifferentGradesWillBeJoinedTogether() throws {
        let sut = try TrackGraph(coords: [
            .leipzig,
            .leipzig.offset(distance: 2000, grade: 0.05),
            .leipzig.offset(distance: 3000, grade: 0.06),
            .leipzig.offset(distance: 5000, grade: 0.07)
        ], elevationSmoothing: .segmentation(50))

        let expectedDistance = sut.heightMap.last!.distance
        let expectedTotalElevation = sut.heightMap.last!.elevation - sut.heightMap.first!.elevation
        let expected = Climb(
            start: sut.heightMap[0].distance,
            end: sut.heightMap.last!.distance,
            bottom: sut.heightMap.first!.elevation,
            top: sut.heightMap.last!.elevation,
            totalElevation: expectedTotalElevation,
            grade: expectedGrade(elevation: expectedTotalElevation, distance: expectedDistance),
            maxGrade: expectedGrade(for: sut.heightMap[2], end: sut.heightMap[3]),
            score: expectedScore(start: sut.heightMap[0], end: sut.heightMap[1]) +
                expectedScore(start: sut.heightMap[1], end: sut.heightMap[2]) +
                expectedScore(start: sut.heightMap[2], end: sut.heightMap[3])
        )

        expectNoDifference([expected], sut.climbs())
    }

    @Test
    func testItJoinsAdjacentSegmentsWithTheSameGrade() throws {
        let sut = try TrackGraph(coords: (1 ... 10).map {
            .kreisel.offset(north: Double($0) * 1000, elevation: Double($0) * 100)
        }, elevationSmoothing: .segmentation(50))

        expectNoDifference([
            Climb(
                start: sut.heightMap.first!.distance,
                end: sut.heightMap.last!.distance,
                bottom: sut.heightMap.first!.elevation,
                top: sut.heightMap.last!.elevation,
                totalElevation: sut.heightMap.last!.elevation - sut.heightMap.first!.elevation,
                grade: expectedGrade(for: sut.heightMap.first!, end: sut.heightMap.last!),
                maxGrade: expectedGrade(for: sut.heightMap.first!, end: sut.heightMap.last!),
                score: expectedScore(start: sut.heightMap.first!, end: sut.heightMap.last!)
            )
        ], sut.climbs())
    }

    @Test
    func testFlatSectionsBetweenClimbsWillBeOmitted() throws {
        let sut = try TrackGraph(coords: [
            // 1st climb
            .dehner,
            .dehner.offset(distance: 2000, grade: 0.055),
            // descent & flat section
            .dehner.offset(east: 2100, elevation: 70),
            .dehner.offset(east: 3000, elevation: 70),
            // 2nd climb
            .leipzig.offset(distance: 5000, grade: 0.055)
        ], elevationSmoothing: .segmentation(50))

        let expectedA = Climb(
            start: sut.heightMap[0].distance,
            end: sut.heightMap[1].distance,
            bottom: sut.heightMap[0].elevation,
            top: sut.heightMap[1].elevation,
            totalElevation: sut.heightMap[1].elevation - sut.heightMap[0].elevation,
            grade: expectedGrade(for: sut.heightMap[0], end: sut.heightMap[1]),
            maxGrade: expectedGrade(for: sut.heightMap[0], end: sut.heightMap[1]),
            score: expectedScore(start: sut.heightMap[0], end: sut.heightMap[1])
        )

        let expectedB = Climb(
            start: sut.heightMap[3].distance,
            end: sut.heightMap[4].distance,
            bottom: sut.heightMap[3].elevation,
            top: sut.heightMap[4].elevation,
            totalElevation: sut.heightMap[4].elevation - sut.heightMap[3].elevation,
            grade: expectedGrade(for: sut.heightMap[3], end: sut.heightMap[4]),
            maxGrade: expectedGrade(for: sut.heightMap[3], end: sut.heightMap[4]),
            score: expectedScore(start: sut.heightMap[3], end: sut.heightMap[4])
        )

        expectNoDifference([expectedA, expectedB], sut.climbs())
    }

    @Test
    func testItFiltersOutClimbsWithGradeLessThanMinimumGrade() throws {
        let sut = try TrackGraph(coords: [
            .leipzig,
            .leipzig.offset(distance: 3000, grade: 0.05),
            .leipzig.offset(distance: 6000, grade: 0.049)
        ], elevationSmoothing: .segmentation(50))

        let expected = Climb(
            start: sut.heightMap[0].distance,
            end: sut.heightMap[1].distance,
            bottom: sut.heightMap[0].elevation,
            top: sut.heightMap[1].elevation,
            totalElevation: sut.heightMap[1].elevation - sut.heightMap[0].elevation,
            grade: expectedGrade(for: sut.heightMap[0], end: sut.heightMap[1]),
            maxGrade: expectedGrade(for: sut.heightMap[0], end: sut.heightMap[1]),
            score: expectedScore(start: sut.heightMap[0], end: sut.heightMap[1])
        )

        expectNoDifference([expected], sut.climbs(minimumGrade: 0.05))
    }

    @Test
    func testJoiningClimbsWithinMaxJoinDistance() throws {
        let sut = try TrackGraph(coords: [
            .leipzig,
            .leipzig.offset(east: 2000, elevation: 100),
            .leipzig.offset(east: 2100, elevation: 80),
            .leipzig.offset(east: 300, elevation: 300)
        ], elevationSmoothing: .segmentation(50))

        let expectedTotalElevation = 100.0 + (300.0 - 80.0)
        let expected = Climb(
            start: sut.heightMap[0].distance,
            end: sut.heightMap.last!.distance,
            bottom: sut.heightMap[0].elevation,
            top: sut.heightMap.last!.elevation,
            totalElevation: expectedTotalElevation,
            grade: expectedGrade(elevation: expectedTotalElevation, distance: sut.distance),
            maxGrade: expectedGrade(for: sut.heightMap[2], end: sut.heightMap[3]),
            score: expectedScore(start: sut.heightMap[0], end: sut.heightMap[1]) + expectedScore(
                start: sut.heightMap[2],
                end: sut.heightMap[3]
            )
        )

        expectNoDifference([expected], sut.climbs(minimumGrade: 0.05, maxJoinDistance: 200.0))

        expectNoDifference([
            Climb(
                start: sut.heightMap[0].distance,
                end: sut.heightMap[1].distance,
                bottom: sut.heightMap[0].elevation,
                top: sut.heightMap[1].elevation,
                totalElevation: sut.heightMap[1].elevation - sut.heightMap[0].elevation,
                grade: expectedGrade(for: sut.heightMap[0], end: sut.heightMap[1]),
                maxGrade: expectedGrade(for: sut.heightMap[0], end: sut.heightMap[1]),
                score: expectedScore(start: sut.heightMap[0], end: sut.heightMap[1])
            ),
            Climb(
                start: sut.heightMap[2].distance,
                end: sut.heightMap[3].distance,
                bottom: sut.heightMap[2].elevation,
                top: sut.heightMap[3].elevation,
                totalElevation: sut.heightMap[3].elevation - sut.heightMap[2].elevation,
                grade: expectedGrade(for: sut.heightMap[2], end: sut.heightMap[3]),
                maxGrade: expectedGrade(for: sut.heightMap[2], end: sut.heightMap[3]),
                score: expectedScore(start: sut.heightMap[2], end: sut.heightMap[3])
            )
        ], sut.climbs(minimumGrade: 0.05, maxJoinDistance: 50))
    }

    @Test
    func testGradeSegmentsForEmptyGraphIsEmptyArray() throws {
        let sut = try TrackGraph(coords: [], elevationSmoothing: .segmentation(50))

        expectNoDifference([], sut.gradeSegments)
    }

    @Test
    func testGraphWithTheSameGrade() throws {
        let sut = try TrackGraph(
            coords: [.leipzig, .leipzig.offset(north: 1000, elevation: 100)],
            elevationSmoothing: .segmentation(25)
        )

        expectNoDifference(
            [GradeSegment(start: 0, end: sut.distance, elevationAtStart: 0, elevationAtEnd: 100)],
            sut.gradeSegments
        )
    }

    @Test
    func testGraphWithVaryingGradeHasSegmentsInTheSpecifiedLength() throws {
        let first: Coordinate = .leipzig.offset(distance: 100, grade: 0.1)
        let second: Coordinate = first.offset(distance: 100, grade: 0.2)
        let sut = try TrackGraph(coords: [
            .leipzig,
            first,
            second
        ], elevationSmoothing: .segmentation(25))

        let expected: [GradeSegment] = try [
            #require(.init(start: 0, end: 100, grade: 0.1, elevationAtStart: 0)),
            #require(.init(start: 100, end: sut.distance, grade: 0.2, elevationAtStart: 10))
        ]
        expectNoDifference(expected, sut.gradeSegments)
    }

    @Test
    func testGraphShorterThanSegmentDistance() throws {
        let sut = try TrackGraph(coords: [
            .leipzig,
            .leipzig.offset(distance: 50, grade: 0.3)
        ], elevationSmoothing: .segmentation(100))

        let expected: [GradeSegment] = try [
            #require(GradeSegment(start: 0, end: sut.distance, elevationAtStart: 0, elevationAtEnd: 14.57))
        ]
        expectNoDifference(expected, sut.gradeSegments)
    }

    @Test
    func testNegativeGrades() throws {
        let start = Coordinate.leipzig.offset(elevation: 100)
        let first: Coordinate = start.offset(distance: 100, grade: 0.1)
        let second: Coordinate = first.offset(distance: 100, grade: 0.2)
        let third: Coordinate = second.offset(distance: 100, grade: -0.3)
        let sut = try TrackGraph(coords: [
            start,
            first,
            second,
            third
        ], elevationSmoothing: .segmentation(50))

        let expected: [GradeSegment] = try [
            #require(.init(start: 0, end: 100, elevationAtStart: 100, elevationAtEnd: 109.98)),
            #require(.init(start: 100, end: 200, elevationAtStart: 109.98, elevationAtEnd: 129.64)),
            #require(.init(
                start: 200,
                end: sut.distance,
                elevationAtStart: 129.64,
                elevationAtEnd: 100.56
            ))
        ]
        expectNoDifference(expected, sut.gradeSegments)
    }

    @Test
    func testGradeSegmentsWhenInitializedFromDefaultInitializer() throws {
        let start = Coordinate.leipzig.offset(elevation: 100)
        let first: Coordinate = start.offset(distance: 100, grade: 0.1)
        let second: Coordinate = first.offset(distance: 100, grade: 0.2)
        let third: Coordinate = second.offset(distance: 100, grade: -0.3)
        let fourth: Coordinate = third.offset(distance: 50, grade: 0.06)
        let sut = try TrackGraph(points: [
            start,
            first,
            second,
            third,
            fourth
        ].map { TrackPoint(coordinate: $0) }, elevationSmoothing: .segmentation(50))

        let expected: [GradeSegment] = try [
            #require(.init(start: 0, end: 100, grade: 0.1, elevationAtStart: 100)),
            #require(.init(start: 100, end: 200, grade: 0.2, elevationAtStart: 110)),
            #require(.init(start: 200, end: 300, grade: -0.3, elevationAtStart: 129.64)),
            #require(.init(
                start: 300,
                end: sut.distance,
                grade: 0.06,
                elevationAtStart: 100.58
            ))
        ]
        expectNoDifference(expected, sut.gradeSegments)
    }

    @Test
    func testElevationAtDistanceTestBeyondTheTracksBounds() throws {
        let start = Coordinate.leipzig.offset(elevation: 100)
        let end: Coordinate = start.offset(distance: 100, grade: 0.1)
        let sut = try TrackGraph(coords: [
            start,
            end
        ], elevationSmoothing: .segmentation(50))

        #expect(sut.elevation(at: -10) == nil)
        #expect(sut.elevation(at: Double.greatestFiniteMagnitude) == nil)
        #expect(sut.elevation(at: -Double.greatestFiniteMagnitude) == nil)
        #expect(sut.elevation(at: sut.distance + 1) == nil)
        #expect(sut.elevation(at: sut.distance + 100) == nil)
    }

    @Test
    func testElevationAtDistanceForDistancesAtCoordinates() throws {
        let start = Coordinate.leipzig.offset(elevation: 100)
        let first = start.offset(distance: 100, grade: 0.1)
        let second = first.offset(distance: 100, grade: 0.2)
        let third = second.offset(distance: 100, grade: -0.3)
        let coords = [
            start,
            first,
            second,
            third
        ]
        let sut = try TrackGraph(coords: coords, elevationSmoothing: .segmentation(50))

        expectNoDifference(start.elevation, sut.elevation(at: 0))

        #expect(first.elevation.isApproximatelyEqual(
            to: try #require(sut.elevation(at: start.distance(to: first))),
            absoluteTolerance: 0.001
        ))
        #expect(second.elevation.isApproximatelyEqual(
            to: try #require(sut.elevation(at: start.distance(to: second))),
            absoluteTolerance: 0.001
        ))
        #expect(third.elevation.isApproximatelyEqual(
            to: try #require(sut.elevation(at: start.distance(to: third))),
            absoluteTolerance: 0.001
        ))
        #expect(third.elevation.isApproximatelyEqual(
            to: try #require(sut.elevation(at: sut.distance)),
            absoluteTolerance: 0.001
        ))
    }

    @Test
    func testElevationAtDistanceForDistancesBetweenCoordinates() throws {
        let start = Coordinate.leipzig.offset(elevation: 100)
        let first = start.offset(distance: 100, grade: 0.1)
        let second = first.offset(distance: 100, grade: 0.2)
        let third = second.offset(distance: 100, grade: -0.3)
        let coords = [
            start,
            first,
            second,
            third
        ]
        let sut = try TrackGraph(coords: coords, elevationSmoothing: .segmentation(50))

        for (lhs, rhs) in sut.heightMap.adjacentPairs() {
            let distanceDelta = rhs.distance - lhs.distance
            let heightDelta = rhs.elevation - lhs.elevation
            for t in stride(from: 0, through: 1, by: 0.1) {
                let expectedHeight = lhs.elevation + t * heightDelta

                #expect(expectedHeight.isApproximatelyEqual(
                    to: try #require(sut.elevation(at: lhs.distance + distanceDelta * t)),
                    absoluteTolerance: 0.001
                ))
            }
        }
    }

    @Test
    func testInitializationFromCoordinates() throws {
        let start = Coordinate.leipzig.offset(elevation: 100)
        let first = start.offset(distance: 100, grade: 0.1)
        let second = first.offset(distance: 100, grade: 0.2)
        let third = second.offset(distance: 100, grade: -0.3)
        let coords = [
            start,
            first,
            second,
            third
        ]
        let sut = TrackGraph(coords: coords)

        let expected = [
            DistanceHeight(distance: 0, elevation: 100),
            DistanceHeight(distance: 99.88810211970392, elevation: 109.96686524911621),
            DistanceHeight(distance: 199.77620423940783, elevation: 129.70642123410428),
            DistanceHeight(distance: 299.6643063591117, elevation: 100.56074178631758)
        ]
        expectNoDifference(expected, sut.heightMap)
        expectNoDifference(29.706421234104283, sut.elevationGain)
        try expectNoDifference(#require(expected.last).distance, sut.distance)
        expectNoDifference([
            GradeSegment(start: 0, end: 99.88810211970392, grade: 0.1, elevationAtStart: 100),
            GradeSegment(start: 99.88810211970392, end: 199.77620423940783, grade: 0.2, elevationAtStart: 110),
            GradeSegment(
                start: 199.77620423940783,
                end: 299.6643063591117,
                elevationAtStart: 129.70642123410428,
                elevationAtEnd: 100.56074178631758
            )
        ], sut.gradeSegments)
        expectNoDifference(sut.distance, sut.gradeSegments.last?.end)
    }
}
