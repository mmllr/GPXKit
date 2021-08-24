import XCTest
@testable import GPXKit

class TrackGraphTests: XCTestCase {
    var sut: TrackGraph!
    let coordinates: [Coordinate] = [
        Coordinate(latitude: 51.2763320, longitude: 12.3767670, elevation: 82.2),
        Coordinate(latitude: 51.2763700, longitude: 12.3767550, elevation: 82.2),
        Coordinate(latitude: 51.2764100, longitude: 12.3767400, elevation: 82.2),
        Coordinate(latitude: 51.2764520, longitude: 12.3767260, elevation: 82.2),
        Coordinate(latitude: 51.2765020, longitude: 12.3767050, elevation: 82.2),
    ]

    override func setUp() {
        super.setUp()
        sut = TrackGraph(coords: coordinates)
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func givenAPoint(latitude: Double, longitude: Double, elevation: Double) -> TrackPoint {
        return TrackPoint(coordinate: Coordinate(latitude: latitude, longitude: longitude, elevation: elevation), date: Date())
    }

    func expectedDistance(from: Coordinate, to: Coordinate) -> Double {
        return from.distance(to: to)
    }

    func expectedGrade(for start: DistanceHeight, end: DistanceHeight) -> Double {
        (end.elevation - start.elevation) / (end.distance - start.distance).magnitude
    }

    func expectedScore(start: DistanceHeight, end: DistanceHeight) -> Double {
        let distance = end.distance - start.distance
        let height = end.elevation - start.elevation
        // FIETS Score = (H * H / (D * 10)) + (T - 1000) / 1000 Note: The last part (+ (T - 1000) / 1000) will be omitted
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

    func testTotalElevationWithTheSameElevationAtEveryPoint() {
        let coordinates: [Coordinate] = [
            Coordinate(latitude: 51.2763320, longitude: 12.3767670, elevation: 1),
            Coordinate(latitude: 51.2763700, longitude: 12.3767550, elevation: 1),
            Coordinate(latitude: 51.2764100, longitude: 12.3767400, elevation: 1),
            Coordinate(latitude: 51.2764520, longitude: 12.3767260, elevation: 1),
            Coordinate(latitude: 51.2765020, longitude: 12.3767050, elevation: 1),
        ]

        sut = TrackGraph(coords: coordinates)

        XCTAssertEqual(0, sut.elevationGain)
    }

    func testTotalElevationWithDifferentElevation() {
        let coordinates: [Coordinate] = [
            Coordinate(latitude: 51.2763320, longitude: 12.3767670, elevation: 1),
            Coordinate(latitude: 51.2763700, longitude: 12.3767550, elevation: 11), // 10
            Coordinate(latitude: 51.2764100, longitude: 12.3767400, elevation: 5), // -6
            Coordinate(latitude: 51.2764520, longitude: 12.3767260, elevation: 100), // 95
            Coordinate(latitude: 51.2765020, longitude: 12.3767050, elevation: 76), // -24
            Coordinate(latitude: 51.2765520, longitude: 12.3766820, elevation: 344), // 268
        ]

        sut = TrackGraph(coords: coordinates)

        // 10 + 95 + 268
        XCTAssertEqual(373, sut.elevationGain)
    }

    func testInitializationFromGPX() {
        let points: [TrackPoint] = [
            givenAPoint(latitude: 51.2763320, longitude: 12.3767670, elevation: 1),
            givenAPoint(latitude: 51.2763700, longitude: 12.3767550, elevation: 1),
            givenAPoint(latitude: 51.2764100, longitude: 12.3767400, elevation: 1),
            givenAPoint(latitude: 51.2764520, longitude: 12.3767260, elevation: 1),
            givenAPoint(latitude: 51.2765020, longitude: 12.3767050, elevation: 1),
        ]

        sut = TrackGraph(points: points)

        let expectedCoordinates: [Coordinate] = [
            Coordinate(latitude: 51.2763320, longitude: 12.3767670, elevation: 1),
            Coordinate(latitude: 51.2763700, longitude: 12.3767550, elevation: 1),
            Coordinate(latitude: 51.2764100, longitude: 12.3767400, elevation: 1),
            Coordinate(latitude: 51.2764520, longitude: 12.3767260, elevation: 1),
            Coordinate(latitude: 51.2765020, longitude: 12.3767050, elevation: 1),
        ]
        XCTAssertEqual(expectedCoordinates, sut.segments.map { $0.coordinate })
    }

    func testTheInitialElevationIsSubstractedFromTheElevationGain() {
        let coordinates: [Coordinate] = [
            Coordinate(latitude: 51.2763320, longitude: 12.3767670, elevation: 100),
            Coordinate(latitude: 51.2763700, longitude: 12.3767550, elevation: 110),
            Coordinate(latitude: 51.2764100, longitude: 12.3767400, elevation: 120),
            Coordinate(latitude: 51.2764520, longitude: 12.3767260, elevation: 130),
            Coordinate(latitude: 51.2765020, longitude: 12.3767050, elevation: 140),
            Coordinate(latitude: 51.2765520, longitude: 12.3766820, elevation: 150),
        ]

        sut = TrackGraph(coords: coordinates)

        // 10 + 95 + 268
        XCTAssertEqual(50, sut.elevationGain)
    }

    func testElevationGainIsTheSumOfAllElevationDifferences() {
        let coordinates: [Coordinate] = [
            Coordinate(latitude: 51.2763320, longitude: 12.3767670, elevation: 100),
            Coordinate(latitude: 51.2763700, longitude: 12.3767550, elevation: 130), // 30
            Coordinate(latitude: 51.2764100, longitude: 12.3767400, elevation: 70),
            Coordinate(latitude: 51.2764520, longitude: 12.3767260, elevation: 150), // 80
            Coordinate(latitude: 51.2765020, longitude: 12.3767050, elevation: 140),
            Coordinate(latitude: 51.2765520, longitude: 12.3766820, elevation: 150), // 10
        ]

        sut = TrackGraph(coords: coordinates)

        XCTAssertEqual(30 + 80 + 10, sut.elevationGain)
    }

    func testEmptyTrackGraphHasNoClimbs() {
        sut = TrackGraph(coords: [])

        XCTAssertEqual([], sut.climbs())
    }

    func testClimbsWithOnePointInTrackisEmpty() {
        sut = TrackGraph(coords: [.leipzig])

        XCTAssertEqual([], sut.climbs())
    }

    func testATrackWithTwoPointsHasOneClimb() {
        sut = TrackGraph(coords: [.leipzig, .leipzig.offset(east: 1000, elevation: 50)])

        let expected = Climb(
            start: sut.heightMap.first!.distance,
            end: sut.heightMap.last!.distance,
            bottom: sut.heightMap.first!.elevation,
            top: sut.heightMap.last!.elevation,
            grade: expectedGrade(for: sut.heightMap.first!, end: sut.heightMap.last!),
            score: expectedScore(
                start: sut.heightMap.first!,
                end:sut.heightMap.last!
            )
        )

        XCTAssertEqual([expected], sut.climbs())
    }

    func testDownhillSectionsWillNotBeInTheClimbs() {
        sut = TrackGraph(coords: [.leipzig, .leipzig.offset(north: 1000, elevation: -50)])

        XCTAssertEqual([], sut.climbs())
    }

    func testMultipleClimbSegmentsWithDifferentGrades() {
        sut = TrackGraph(coords: [
            .leipzig,
            .leipzig.offset(distance: 2_000, grade: 0.05),
            .leipzig.offset(distance: 3_000, grade: 0.06)
        ])

        let expectedA = Climb(
            start: sut.heightMap[0].distance,
            end: sut.heightMap[1].distance,
            bottom: sut.heightMap[0].elevation,
            top: sut.heightMap[1].elevation,
            grade: expectedGrade(for: sut.heightMap[0], end: sut.heightMap[1]),
            score: expectedScore(start: sut.heightMap[0], end: sut.heightMap[1])
        )

        let expectedB = Climb(
            start: sut.heightMap[1].distance,
            end: sut.heightMap[2].distance,
            bottom: sut.heightMap[1].elevation,
            top: sut.heightMap[2].elevation,
            grade: expectedGrade(for: sut.heightMap[1], end: sut.heightMap[2]),
            score: expectedScore(start: sut.heightMap[1], end: sut.heightMap[2])
        )

        XCTAssertEqual([expectedA, expectedB], sut.climbs())
    }

    func testItJoinsAdjacentSegmentsWithTheSameGrade() {
        sut = TrackGraph(coords: (1...10).map {
            .kreisel.offset(north: Double($0) * 1000, elevation: Double($0) * 100)
        })

        XCTAssertEqual([
            Climb(
                start: sut.heightMap.first!.distance,
                end: sut.heightMap.last!.distance,
                bottom: sut.heightMap.first!.elevation,
                top: sut.heightMap.last!.elevation,
                grade: expectedGrade(for: sut.heightMap.first!, end: sut.heightMap.last!),
                score: expectedScore(start: sut.heightMap.first!, end: sut.heightMap.last!)
            )
        ], sut.climbs())
    }

    func testFlatSectionsBetweenClimbsWillBeOmitted() {
        sut = TrackGraph(coords: [
            // 1st climb
            .dehner,
            .dehner.offset(distance: 2_000, grade: 0.055),
            // descent & flat section
            .dehner.offset(east: 2100, elevation: 70),
            .dehner.offset(east: 3000, elevation: 70),
            // 2nd climb
            .leipzig.offset(distance: 5_000, grade: 0.055)
        ])

        let expectedA = Climb(
            start: sut.heightMap[0].distance,
            end: sut.heightMap[1].distance,
            bottom: sut.heightMap[0].elevation,
            top: sut.heightMap[1].elevation,
            grade: expectedGrade(for: sut.heightMap[0], end: sut.heightMap[1]),
            score: expectedScore(start: sut.heightMap[0], end: sut.heightMap[1])
        )

        let expectedB = Climb(
            start: sut.heightMap[3].distance,
            end: sut.heightMap[4].distance,
            bottom: sut.heightMap[3].elevation,
            top: sut.heightMap[4].elevation,
            grade: expectedGrade(for: sut.heightMap[3], end: sut.heightMap[4]),
            score: expectedScore(start: sut.heightMap[3], end: sut.heightMap[4])
        )

        XCTAssertEqual([expectedA, expectedB], sut.climbs())
    }

    func testItFiltersOutClimbsWithGradeLessThanMinimumGrade() {
        sut = TrackGraph(coords: [
            .leipzig,
            .leipzig.offset(distance: 3_000, grade: 0.05),
            .leipzig.offset(distance: 6_000, grade: 0.049)
        ])

        let expected = Climb(
            start: sut.heightMap[0].distance,
            end: sut.heightMap[1].distance,
            bottom: sut.heightMap[0].elevation,
            top: sut.heightMap[1].elevation,
            grade: expectedGrade(for: sut.heightMap[0], end: sut.heightMap[1]),
            score: expectedScore(start: sut.heightMap[0], end: sut.heightMap[1])
        )

        XCTAssertEqual([expected], sut.climbs(minimumGrade: 0.05))
    }
}
