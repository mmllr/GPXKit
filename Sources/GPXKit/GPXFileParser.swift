import Algorithms
import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

/// Error describing export errors
public enum GPXParserError: Error, Equatable {
    /// The provided xml contains no valid GPX.
    case invalidGPX
    // No tracks where found in the provided GPX xml.
    case noTracksFound
    /// The provided xml could not be parsed. Contains the underlying NSError from the XMLParser along with the xml
    /// files line number where the error occurred.
    case parseError(NSError, Int)
    /// The elevation smoothing failed. See ``ElevationSmoothing`` for details.
    case smoothingError
}

internal enum GPXTags: String {
    case gpx
    case metadata
    case waypoint = "wpt"
    case time
    case track = "trk"
    case route = "rte"
    case routePoint = "rtept"
    case name
    case trackPoint = "trkpt"
    case trackSegment = "trkseg"
    case elevation = "ele"
    case extensions
    case power
    case description = "desc"
    case keywords
    case comment = "cmt"
    case trackPointExtension = "trackpointextension"
    case temperature = "atemp"
    case heartrate = "hr"
    case cadence = "cad"
    case speed
}

internal enum GPXAttributes: String {
    case latitude = "lat"
    case longitude = "lon"
}

/// Class for importing a GPX xml to an ``GPXTrack`` value.
public final class GPXFileParser {
    private let xml: String

    /// Initializer
    /// - Parameter xmlString: The GPX xml string. See [GPX specification for
    /// details](https://www.topografix.com/gpx.asp).
    public init(xmlString: String) {
        self.xml = xmlString
    }

    /// Parses the GPX xml.
    /// - Returns: A ``Result`` of the ``GPXTrack`` in the success or an ``GPXParserError`` in the failure case.
    /// - Parameter elevationSmoothing: The ``ElevationSmoothing`` in meters for the grade segments. Defaults to ``ElevationSmoothing/none``.
    public func parse(elevationSmoothing: ElevationSmoothing = .none) -> Result<GPXTrack, GPXParserError> {
        let parser = BasicXMLParser(xml: xml)
        switch parser.parse() {
        case let .success(root):
            do {
                let track = try parseRoot(node: root, elevationSmoothing: elevationSmoothing)
                return .success(track)
            } catch {
                return .failure(.smoothingError)
            }
        case let .failure(error):
            switch error {
            case .noContent:
                return .failure(.invalidGPX)
            case let .parseError(error, lineNumber):
                return .failure(.parseError(error, lineNumber))
            }
        }
    }

    private func parseRoot(node: XMLNode, elevationSmoothing: ElevationSmoothing) throws -> GPXTrack {
        guard let trackNode = node.childFor(.track) ?? node.childFor(.route) else {
            return try GPXTrack(
                date: node.childFor(.metadata)?.childFor(.time)?.date,
                waypoints: parseWaypoints(node.childrenOfType(.waypoint)),
                title: "",
                description: nil,
                trackPoints: [],
                keywords: parseKeywords(node: node),
                elevationSmoothing: elevationSmoothing
            )
        }
        let title = trackNode.childFor(.name)?.content ?? ""
        let isRoute = trackNode.name == GPXTags.route.rawValue
        let (trackPoints, segments) = isRoute ? parseRoute(trackNode) : parseSegment(trackNode.childrenOfType(.trackSegment))
        return try GPXTrack(
            date: node.childFor(.metadata)?.childFor(.time)?.date,
            waypoints: parseWaypoints(node.childrenOfType(.waypoint)),
            title: title,
            description: trackNode.childFor(.description)?.content,
            trackPoints: trackPoints,
            keywords: parseKeywords(node: node),
            elevationSmoothing: elevationSmoothing,
            segments: segments
        )
    }

    private func parseWaypoints(_ nodes: [XMLNode]) -> [Waypoint]? {
        guard !nodes.isEmpty else { return nil }
        return nodes.compactMap { Waypoint($0) ?? nil }
    }

    private func parseKeywords(node: XMLNode) -> [String] {
        node.childFor(.metadata)?
            .childFor(.keywords)?
            .content.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty } ?? []
    }

    private func parseMetaData(_ node: XMLNode) -> Date? {
        return node.childFor(.time)?.date
    }

    private func parseSegment(_ segmentNodes: [XMLNode]) -> ([TrackPoint], [GPXTrack.Segment]?) {
        guard !segmentNodes.isEmpty else { return ([], nil) }

        let segmented = segmentNodes.map {
            $0.childrenOfType(.trackPoint).compactMap(TrackPoint.init)
        }
        var trackPoints = segmented.flatMap { $0 }
        let segments = segmented.reduce(into: [GPXTrack.Segment]()) { acc, segNode in
            guard let last = acc.last else {
                acc.append(.init(range: 0..<segNode.count, distance: segNode.totalDistance))
                return
            }
            let start = last.range.count
            acc.append(.init(range: start ..< start + segNode.count, distance: segNode.totalDistance))
        }
        checkForInvalidElevationAtStartAndEnd(trackPoints: &trackPoints)
        return (correctElevationGaps(trackPoints: trackPoints)
            .map {
                .init(
                    coordinate: .init(
                        latitude: $0.latitude,
                        longitude: $0.longitude,
                        elevation: $0.coordinate.elevation == .greatestFiniteMagnitude ? 0 : $0.coordinate
                            .elevation
                    ),
                    date: $0.date,
                    power: $0.power,
                    cadence: $0.cadence,
                    heartrate: $0.heartrate,
                    temperature: $0.temperature,
                    speed: $0.speed
                )
            }, segments)
    }

    private func parseRoute(_ routeNode: XMLNode?) -> ([TrackPoint], [GPXTrack.Segment]?) {
        guard let node = routeNode else {
            return ([], nil)
        }
        var trackPoints = node.childrenOfType(.routePoint).compactMap(TrackPoint.init)
        checkForInvalidElevationAtStartAndEnd(trackPoints: &trackPoints)
        return (correctElevationGaps(trackPoints: trackPoints)
            .map {
                .init(
                    coordinate: .init(
                        latitude: $0.latitude,
                        longitude: $0.longitude,
                        elevation: $0.coordinate.elevation == .greatestFiniteMagnitude ? 0 : $0.coordinate
                            .elevation
                    ),
                    date: $0.date,
                    power: $0.power,
                    cadence: $0.cadence,
                    heartrate: $0.heartrate,
                    temperature: $0.temperature,
                    speed: $0.speed
                )
            }, nil)
    }

    private func checkForInvalidElevationAtStartAndEnd(trackPoints: inout [TrackPoint]) {
        if
            trackPoints.first?.coordinate.elevation == .greatestFiniteMagnitude,
            let firstValidElevation = trackPoints.first(where: { $0.coordinate.elevation != .greatestFiniteMagnitude })?
                .coordinate.elevation
        {
            trackPoints[0].coordinate.elevation = firstValidElevation
        }
        if
            trackPoints.last?.coordinate.elevation == .greatestFiniteMagnitude,
            let lastValidElevation = trackPoints.last(where: { $0.coordinate.elevation != .greatestFiniteMagnitude })?
                .coordinate.elevation
        {
            trackPoints[trackPoints.count - 1].coordinate.elevation = lastValidElevation
        }
    }

    private func correctElevationGaps(trackPoints: [TrackPoint]) -> [TrackPoint] {
        struct Grade {
            var start: Coordinate
            var grade: Double
        }

        let chunks = trackPoints.chunked(on: { $0.coordinate.elevation == .greatestFiniteMagnitude })
        let grades: [Grade] = chunks.filter {
            $0.0 == false
        }.adjacentPairs().compactMap { seq1, seq2 in
            guard
                let start = seq1.1.last,
                let end = seq2.1.first
            else {
                return nil
            }
            let dist = start.coordinate.distance(to: end.coordinate)
            let elevationDelta = end.coordinate.elevation - start.coordinate.elevation
            return Grade(start: start.coordinate, grade: elevationDelta / dist)
        }
        var corrected: [[TrackPoint]] = zip(chunks.filter(\.0), grades).map { chunk, grade in
            return chunk.1.map {
                TrackPoint(
                    coordinate: .init(
                        latitude: $0.latitude,
                        longitude: $0.longitude,
                        elevation: grade.start.elevation + grade.start.distance(to: $0.coordinate) * grade.grade
                    ),
                    date: $0.date,
                    power: $0.power,
                    cadence: $0.cadence,
                    heartrate: $0.heartrate,
                    temperature: $0.temperature
                )
            }
        }

        var result: [TrackPoint] = []
        for chunk in chunks {
            if !corrected.isEmpty, chunk.0 {
                result.append(contentsOf: corrected.removeFirst())
            } else {
                result.append(contentsOf: chunk.1)
            }
        }
        return result
    }
}

extension Waypoint {
    init?(_ waypointNode: XMLNode) {
        guard
            let lat = waypointNode.latitude,
            let lon = waypointNode.longitude
        else {
            return nil
        }
        let elevation = waypointNode.childFor(.elevation)?.elevation ?? .zero
        self.coordinate = Coordinate(
            latitude: lat,
            longitude: lon,
            elevation: elevation
        )
        self.date = waypointNode.childFor(.time)?.date
        self.name = waypointNode.childFor(.name)?.content
        self.comment = waypointNode.childFor(.comment)?.content
        self.description = waypointNode.childFor(.description)?.content
    }
}

extension TrackPoint {
    init?(trackNode: XMLNode) {
        guard
            let lat = trackNode.latitude,
            let lon = trackNode.longitude
        else {
            return nil
        }
        self.coordinate = Coordinate(
            latitude: lat,
            longitude: lon,
            elevation: trackNode.childFor(.elevation)?.elevation ?? .greatestFiniteMagnitude
        )
        self.date = trackNode.childFor(.time)?.date
        self.power = trackNode.childFor(.extensions)?.childFor(.power)?.power
        self.cadence = trackNode.childFor(.extensions)?.childFor(.trackPointExtension)?.childFor(.cadence)
            .flatMap { UInt($0.content) }
        self.heartrate = trackNode.childFor(.extensions)?.childFor(.trackPointExtension)?.childFor(.heartrate)
            .flatMap { UInt($0.content) }
        self.temperature = trackNode.childFor(.extensions)?.childFor(.trackPointExtension)?.childFor(.temperature)?
            .temperature
        self.speed = trackNode.childFor(.extensions)?.childFor(.trackPointExtension)?.childFor(.speed)?.speed
    }
}

extension Collection<TrackPoint> {
    var totalDistance: Double {
        zip(self, self.dropFirst()).map {
            $0.calculateDistance(to: $1)
        }.reduce(0, +)
    }
}

extension XMLNode {
    var latitude: Double? {
        Double(attributes[GPXAttributes.latitude.rawValue] ?? "")
    }

    var longitude: Double? {
        Double(attributes[GPXAttributes.longitude.rawValue] ?? "")
    }

    var elevation: Double? {
        Double(content)
    }

    var date: Date? {
        if let date = ISO8601DateFormatter.importing.date(from: content) {
            return date
        } else {
            return ISO8601DateFormatter.importingFractionalSeconds.date(from: content)
        }
    }

    var power: Measurement<UnitPower>? {
        Double(content).flatMap {
            Measurement<UnitPower>(value: $0, unit: .watts)
        }
    }

    var temperature: Measurement<UnitTemperature>? {
        Double(content).flatMap {
            Measurement<UnitTemperature>(value: $0, unit: .celsius)
        }
    }

    var speed: Measurement<UnitSpeed>? {
        Double(content).flatMap {
            Measurement<UnitSpeed>(value: $0, unit: .metersPerSecond)
        }
    }

    func childFor(_ tag: GPXTags) -> XMLNode? {
        children.first(where: {
            $0.name.lowercased() == tag.rawValue
        })
    }

    func childrenOfType(_ tag: GPXTags) -> [XMLNode] {
        children.filter {
            $0.name.lowercased() == tag.rawValue
        }
    }
}

public extension GPXFileParser {
    /// Convenience initialize for loading a GPX file from an url. Fails if the track cannot be parsed.
    /// - Parameter url: The url containing the GPX file. See [GPX specification for
    /// details](https://www.topografix.com/gpx.asp).
    /// - Returns: An `GPXFileParser` instance or nil if the track cannot be parsed.
    convenience init?(url: URL) {
        guard let xmlString = try? String(contentsOf: url) else { return nil }
        self.init(xmlString: xmlString)
    }

    /// Convenience initialize for loading a GPX file from a data. Returns nil if the track cannot be parsed.
    /// - Parameter data: Data containing the GPX file as encoded xml string. See [GPX specification for
    /// details](https://www.topografix.com/gpx.asp).
    /// - Returns: An `GPXFileParser` instance or nil if the track cannot be parsed.
    convenience init?(data: Data) {
        guard let xmlString = String(data: data, encoding: .utf8) else { return nil }
        self.init(xmlString: xmlString)
    }
}
