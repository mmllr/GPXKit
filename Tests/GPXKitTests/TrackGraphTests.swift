import CustomDump
import GPXKit
import XCTest

final class TrackGraphTests: XCTestCase {
    var sut: TrackGraph!
    let coordinates: [Coordinate] = [
        Coordinate(latitude: 51.2763320, longitude: 12.3767670, elevation: 82.2),
        Coordinate(latitude: 51.2763700, longitude: 12.3767550, elevation: 82.2),
        Coordinate(latitude: 51.2764100, longitude: 12.3767400, elevation: 82.2),
        Coordinate(latitude: 51.2764520, longitude: 12.3767260, elevation: 82.2),
        Coordinate(latitude: 51.2765020, longitude: 12.3767050, elevation: 82.2),
    ]

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = try TrackGraph(coords: coordinates, elevationSmoothing: .segmentation(50))
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

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

    func testSegmentDistances() {
        let expectedDistances = [0.0] + zip(coordinates, coordinates.dropFirst()).map {
            expectedDistance(from: $0, to: $1)
        }

        for (index, expectedDistance) in expectedDistances.enumerated() {
            XCTAssertEqual(sut.segments[index].distanceInMeters, expectedDistance, accuracy: 0.001)
        }
    }

    func testTotalDistance() {
        let totalDistance = zip(coordinates, coordinates.dropFirst()).map {
            expectedDistance(from: $0, to: $1)
        }.reduce(0, +)

        XCTAssertEqual(totalDistance, sut.distance, accuracy: 0.01)
    }

    func testTotalElevationWithTheSameElevationAtEveryPoint() throws {
        let coordinates: [Coordinate] = [
            Coordinate(latitude: 51.2763320, longitude: 12.3767670, elevation: 1),
            Coordinate(latitude: 51.2763700, longitude: 12.3767550, elevation: 1),
            Coordinate(latitude: 51.2764100, longitude: 12.3767400, elevation: 1),
            Coordinate(latitude: 51.2764520, longitude: 12.3767260, elevation: 1),
            Coordinate(latitude: 51.2765020, longitude: 12.3767050, elevation: 1),
        ]

        sut = try TrackGraph(coords: coordinates, elevationSmoothing: .segmentation(50))

        XCTAssertNoDifference(0, sut.elevationGain)
    }

    func testTotalElevationWithDifferentElevation() throws {
        let coordinates: [Coordinate] = [
            Coordinate(latitude: 51.2763320, longitude: 12.3767670, elevation: 1),
            Coordinate(latitude: 51.2763700, longitude: 12.3767550, elevation: 11), // 10
            Coordinate(latitude: 51.2764100, longitude: 12.3767400, elevation: 5), // -6
            Coordinate(latitude: 51.2764520, longitude: 12.3767260, elevation: 100), // 95
            Coordinate(latitude: 51.2765020, longitude: 12.3767050, elevation: 76), // -24
            Coordinate(latitude: 51.2765520, longitude: 12.3766820, elevation: 344), // 268
        ]

        sut = try TrackGraph(coords: coordinates, elevationSmoothing: .segmentation(50))

        // 10 + 95 + 268
        XCTAssertNoDifference(373, sut.elevationGain)
    }

    func testInitializationFromGPX() throws {
        let points: [TrackPoint] = [
            givenAPoint(latitude: 51.2763320, longitude: 12.3767670, elevation: 1),
            givenAPoint(latitude: 51.2763700, longitude: 12.3767550, elevation: 1),
            givenAPoint(latitude: 51.2764100, longitude: 12.3767400, elevation: 1),
            givenAPoint(latitude: 51.2764520, longitude: 12.3767260, elevation: 1),
            givenAPoint(latitude: 51.2765020, longitude: 12.3767050, elevation: 1),
        ]

        sut = try TrackGraph(points: points)

        let expectedCoordinates: [Coordinate] = [
            Coordinate(latitude: 51.2763320, longitude: 12.3767670, elevation: 1),
            Coordinate(latitude: 51.2763700, longitude: 12.3767550, elevation: 1),
            Coordinate(latitude: 51.2764100, longitude: 12.3767400, elevation: 1),
            Coordinate(latitude: 51.2764520, longitude: 12.3767260, elevation: 1),
            Coordinate(latitude: 51.2765020, longitude: 12.3767050, elevation: 1),
        ]
        XCTAssertNoDifference(expectedCoordinates, sut.segments.map { $0.coordinate })
    }

    func testTheInitialElevationIsSubstractedFromTheElevationGain() throws {
        let coordinates: [Coordinate] = [
            Coordinate(latitude: 51.2763320, longitude: 12.3767670, elevation: 100),
            Coordinate(latitude: 51.2763700, longitude: 12.3767550, elevation: 110),
            Coordinate(latitude: 51.2764100, longitude: 12.3767400, elevation: 120),
            Coordinate(latitude: 51.2764520, longitude: 12.3767260, elevation: 130),
            Coordinate(latitude: 51.2765020, longitude: 12.3767050, elevation: 140),
            Coordinate(latitude: 51.2765520, longitude: 12.3766820, elevation: 150),
        ]

        sut = try TrackGraph(coords: coordinates, elevationSmoothing: .segmentation(50))

        // 10 + 95 + 268
        XCTAssertNoDifference(50, sut.elevationGain)
    }

    func testElevationGainIsTheSumOfAllElevationDifferences() throws {
        let coordinates: [Coordinate] = [
            Coordinate(latitude: 51.2763320, longitude: 12.3767670, elevation: 100),
            Coordinate(latitude: 51.2763700, longitude: 12.3767550, elevation: 130), // 30
            Coordinate(latitude: 51.2764100, longitude: 12.3767400, elevation: 70),
            Coordinate(latitude: 51.2764520, longitude: 12.3767260, elevation: 150), // 80
            Coordinate(latitude: 51.2765020, longitude: 12.3767050, elevation: 140),
            Coordinate(latitude: 51.2765520, longitude: 12.3766820, elevation: 150), // 10
        ]

        sut = try TrackGraph(coords: coordinates, elevationSmoothing: .segmentation(50))

        XCTAssertNoDifference(30 + 80 + 10, sut.elevationGain)
    }

    func testEmptyTrackGraphHasNoClimbs() throws {
        sut = try TrackGraph(coords: [], elevationSmoothing: .segmentation(50))

        XCTAssertNoDifference([], sut.climbs())
    }

    func testClimbsWithOnePointInTrackIsEmpty() throws {
        sut = try TrackGraph(coords: [.leipzig], elevationSmoothing: .segmentation(50))

        XCTAssertNoDifference([], sut.climbs())
    }

    func testATrackWithTwoPointsHasOneClimb() throws {
        sut = try TrackGraph(
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

        XCTAssertNoDifference([expected], sut.climbs())
    }

    func testDownhillSectionsWillNotBeInTheClimbs() throws {
        sut = try TrackGraph(
            coords: [.leipzig, .leipzig.offset(north: 1000, elevation: -50)],
            elevationSmoothing: .segmentation(50)
        )

        XCTAssertNoDifference([], sut.climbs())
    }

    func testMultipleAdjacentClimbSegmentsWithDifferentGradesWillBeJoinedTogether() throws {
        sut = try TrackGraph(coords: [
            .leipzig,
            .leipzig.offset(distance: 2000, grade: 0.05),
            .leipzig.offset(distance: 3000, grade: 0.06),
            .leipzig.offset(distance: 5000, grade: 0.07),
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

        XCTAssertNoDifference([expected], sut.climbs())
    }

    func testItJoinsAdjacentSegmentsWithTheSameGrade() throws {
        sut = try TrackGraph(coords: (1 ... 10).map {
            .kreisel.offset(north: Double($0) * 1000, elevation: Double($0) * 100)
        }, elevationSmoothing: .segmentation(50))

        XCTAssertNoDifference([
            Climb(
                start: sut.heightMap.first!.distance,
                end: sut.heightMap.last!.distance,
                bottom: sut.heightMap.first!.elevation,
                top: sut.heightMap.last!.elevation,
                totalElevation: sut.heightMap.last!.elevation - sut.heightMap.first!.elevation,
                grade: expectedGrade(for: sut.heightMap.first!, end: sut.heightMap.last!),
                maxGrade: expectedGrade(for: sut.heightMap.first!, end: sut.heightMap.last!),
                score: expectedScore(start: sut.heightMap.first!, end: sut.heightMap.last!)
            ),
        ], sut.climbs())
    }

    func testFlatSectionsBetweenClimbsWillBeOmitted() throws {
        sut = try TrackGraph(coords: [
            // 1st climb
            .dehner,
            .dehner.offset(distance: 2000, grade: 0.055),
            // descent & flat section
            .dehner.offset(east: 2100, elevation: 70),
            .dehner.offset(east: 3000, elevation: 70),
            // 2nd climb
            .leipzig.offset(distance: 5000, grade: 0.055),
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

        XCTAssertNoDifference([expectedA, expectedB], sut.climbs())
    }

    func testItFiltersOutClimbsWithGradeLessThanMinimumGrade() throws {
        sut = try TrackGraph(coords: [
            .leipzig,
            .leipzig.offset(distance: 3000, grade: 0.05),
            .leipzig.offset(distance: 6000, grade: 0.049),
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

        XCTAssertNoDifference([expected], sut.climbs(minimumGrade: 0.05))
    }

    func testJoiningClimbsWithinMaxJoinDistance() throws {
        sut = try TrackGraph(coords: [
            .leipzig,
            .leipzig.offset(east: 2000, elevation: 100),
            .leipzig.offset(east: 2100, elevation: 80),
            .leipzig.offset(east: 300, elevation: 300),
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

        XCTAssertNoDifference([expected], sut.climbs(minimumGrade: 0.05, maxJoinDistance: 200.0))

        XCTAssertNoDifference([
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
            ),
        ], sut.climbs(minimumGrade: 0.05, maxJoinDistance: 50))
    }

    func testGradeSegmentsForEmptyGraphIsEmptyArray() throws {
        let sut = try TrackGraph(coords: [], elevationSmoothing: .segmentation(50))

        XCTAssertNoDifference([], sut.gradeSegments)
    }

    func testGraphWithTheSameGrade() throws {
        let sut = try TrackGraph(
            coords: [.leipzig, .leipzig.offset(north: 1000, elevation: 100)],
            elevationSmoothing: .segmentation(25)
        )

        XCTAssertNoDifference(
            [GradeSegment(start: 0, end: sut.distance, elevationAtStart: 0, elevationAtEnd: 100)],
            sut.gradeSegments
        )
    }

    func testGraphWithVaryingGradeHasSegmentsInTheSpecifiedLength() throws {
        let first: Coordinate = .leipzig.offset(distance: 100, grade: 0.1)
        let second: Coordinate = first.offset(distance: 100, grade: 0.2)
        let sut = try TrackGraph(coords: [
            .leipzig,
            first,
            second,
        ], elevationSmoothing: .segmentation(25))

        let expected: [GradeSegment] = try [
            XCTUnwrap(.init(start: 0, end: 100, grade: 0.1, elevationAtStart: 0)),
            XCTUnwrap(.init(start: 100, end: sut.distance, grade: 0.2, elevationAtStart: 10)),
        ]
        XCTAssertNoDifference(expected, sut.gradeSegments)
    }

    func testGraphShorterThanSegmentDistance() throws {
        let sut = try TrackGraph(coords: [
            .leipzig,
            .leipzig.offset(distance: 50, grade: 0.3),
        ], elevationSmoothing: .segmentation(100))

        let expected: [GradeSegment] = try [
            XCTUnwrap(GradeSegment(start: 0, end: sut.distance, elevationAtStart: 0, elevationAtEnd: 14.57)),
        ]
        XCTAssertNoDifference(expected, sut.gradeSegments)
    }

    func testNegativeGrades() throws {
        let start = Coordinate.leipzig.offset(elevation: 100)
        let first: Coordinate = start.offset(distance: 100, grade: 0.1)
        let second: Coordinate = first.offset(distance: 100, grade: 0.2)
        let third: Coordinate = second.offset(distance: 100, grade: -0.3)
        let sut = try TrackGraph(coords: [
            start,
            first,
            second,
            third,
        ], elevationSmoothing: .segmentation(50))

        let expected: [GradeSegment] = try [
            XCTUnwrap(.init(start: 0, end: 100, elevationAtStart: 100, elevationAtEnd: 109.98)),
            XCTUnwrap(.init(start: 100, end: 200, elevationAtStart: 109.98, elevationAtEnd: 129.64)),
            XCTUnwrap(.init(
                start: 200,
                end: sut.distance,
                elevationAtStart: 129.64,
                elevationAtEnd: 100.56
            )),
        ]
        XCTAssertNoDifference(expected, sut.gradeSegments)
    }

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
            fourth,
        ].map { TrackPoint(coordinate: $0) }, elevationSmoothing: .segmentation(50))

        let expected: [GradeSegment] = try [
            XCTUnwrap(.init(start: 0, end: 100, grade: 0.1, elevationAtStart: 100)),
            XCTUnwrap(.init(start: 100, end: 200, grade: 0.2, elevationAtStart: 110)),
            XCTUnwrap(.init(start: 200, end: 300, grade: -0.3, elevationAtStart: 129.64)),
            XCTUnwrap(.init(
                start: 300,
                end: sut.distance,
                grade: 0.06,
                elevationAtStart: 100.58
            )),
        ]
        XCTAssertNoDifference(expected, sut.gradeSegments)
    }

    func testElevationAtDistanceTestBeyondTheTracksBounds() throws {
        let start = Coordinate.leipzig.offset(elevation: 100)
        let end: Coordinate = start.offset(distance: 100, grade: 0.1)
        let sut = try TrackGraph(coords: [
            start,
            end,
        ], elevationSmoothing: .segmentation(50))

        XCTAssertNil(sut.elevation(at: -10))
        XCTAssertNil(sut.elevation(at: Double.greatestFiniteMagnitude))
        XCTAssertNil(sut.elevation(at: -Double.greatestFiniteMagnitude))
        XCTAssertNil(sut.elevation(at: sut.distance + 1))
        XCTAssertNil(sut.elevation(at: sut.distance + 100))
    }

    func testElevationAtDistanceForDistancesAtCoordinates() throws {
        let start = Coordinate.leipzig.offset(elevation: 100)
        let first = start.offset(distance: 100, grade: 0.1)
        let second = first.offset(distance: 100, grade: 0.2)
        let third = second.offset(distance: 100, grade: -0.3)
        let coords = [
            start,
            first,
            second,
            third,
        ]
        let sut = try TrackGraph(coords: coords, elevationSmoothing: .segmentation(50))

        XCTAssertNoDifference(start.elevation, sut.elevation(at: 0))
        XCTAssertEqual(first.elevation, try XCTUnwrap(sut.elevation(at: start.distance(to: first))), accuracy: 0.001)
        XCTAssertEqual(second.elevation, try XCTUnwrap(sut.elevation(at: start.distance(to: second))), accuracy: 0.001)
        XCTAssertEqual(third.elevation, try XCTUnwrap(sut.elevation(at: start.distance(to: third))), accuracy: 0.001)
        XCTAssertEqual(third.elevation, try XCTUnwrap(sut.elevation(at: sut.distance)), accuracy: 0.001)
    }

    func testElevationAtDistanceForDistancesBetweenCoordinates() throws {
        let start = Coordinate.leipzig.offset(elevation: 100)
        let first = start.offset(distance: 100, grade: 0.1)
        let second = first.offset(distance: 100, grade: 0.2)
        let third = second.offset(distance: 100, grade: -0.3)
        let coords = [
            start,
            first,
            second,
            third,
        ]
        let sut = try TrackGraph(coords: coords, elevationSmoothing: .segmentation(50))

        for (lhs, rhs) in sut.heightMap.adjacentPairs() {
            let distanceDelta = rhs.distance - lhs.distance
            let heightDelta = rhs.elevation - lhs.elevation
            for t in stride(from: 0, through: 1, by: 0.1) {
                let expectedHeight = lhs.elevation + t * heightDelta

                XCTAssertEqual(
                    expectedHeight,
                    try XCTUnwrap(sut.elevation(at: lhs.distance + distanceDelta * t)),
                    accuracy: 0.0001
                )
            }
        }
    }

    func testInitializationFromCoordinates() throws {
        let start = Coordinate.leipzig.offset(elevation: 100)
        let first = start.offset(distance: 100, grade: 0.1)
        let second = first.offset(distance: 100, grade: 0.2)
        let third = second.offset(distance: 100, grade: -0.3)
        let coords = [
            start,
            first,
            second,
            third,
        ]
        let sut = TrackGraph(coords: coords)

        let expected = [
            DistanceHeight(distance: 0, elevation: 100),
            DistanceHeight(distance: 99.88810211970392, elevation: 109.96686524911621),
            DistanceHeight(distance: 199.77620423940783, elevation: 129.70642123410428),
            DistanceHeight(distance: 299.6643063591117, elevation: 100.56074178631758),
        ]
        XCTAssertNoDifference(expected, sut.heightMap)
        XCTAssertNoDifference(29.706421234104283, sut.elevationGain)
        try XCTAssertNoDifference(XCTUnwrap(expected.last).distance, sut.distance)
        XCTAssertNoDifference([
            GradeSegment(start: 0, end: 99.88810211970392, grade: 0.1, elevationAtStart: 100),
            GradeSegment(start: 99.88810211970392, end: 199.77620423940783, grade: 0.2, elevationAtStart: 110),
            GradeSegment(
                start: 199.77620423940783,
                end: 299.6643063591117,
                elevationAtStart: 129.70642123410428,
                elevationAtEnd: 100.56074178631758
            ),
        ], sut.gradeSegments)
    }
}
