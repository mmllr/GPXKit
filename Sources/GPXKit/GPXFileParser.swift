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
}

internal enum GPXAttributes: String {
    case latitude = "lat"
    case longitude = "lon"
}

/// Class for importing a GPX xml to an `GPXTrack` value.
public final class GPXFileParser {
    private let xml: String

    /// Initializer
    /// - Parameter xmlString: The GPX xml string. See [GPX specification for
    /// details](https://www.topografix.com/gpx.asp).
    public init(xmlString: String) {
        self.xml = xmlString
    }

    /// Parses the GPX xml.
    /// - Returns: A `Result` of the `GPXTrack` in the success or an `GPXParserError` in the failure case.
    /// - Parameter gradeSegmentLength: The length in meters for the grade segments. Defaults to 50 meters.
    public func parse(elevationSmoothing: ElevationSmoothing = .segmentation(50)) -> Result<GPXTrack, GPXParserError> {
        let parser = BasicXMLParser(xml: xml)
        switch parser.parse() {
        case let .success(root):
            let track = parseRoot(node: root, elevationSmoothing: elevationSmoothing)
            return .success(track)
        case let .failure(error):
            switch error {
            case .noContent:
                return .failure(.invalidGPX)
            case let .parseError(error, lineNumber):
                return .failure(.parseError(error, lineNumber))
            }
        }
    }

    private func parseRoot(node: XMLNode, elevationSmoothing: ElevationSmoothing) -> GPXTrack {
        guard let trackNode = node.childFor(.track) ?? node.childFor(.route) else {
            return GPXTrack(
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
        return GPXTrack(
            date: node.childFor(.metadata)?.childFor(.time)?.date,
            waypoints: parseWaypoints(node.childrenOfType(.waypoint)),
            title: title,
            description: trackNode.childFor(.description)?.content,
            trackPoints: isRoute ? parseRoute(trackNode) : parseSegment(trackNode.childFor(.trackSegment)),
            keywords: parseKeywords(node: node),
            elevationSmoothing: elevationSmoothing
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

    private func parseSegment(_ segmentNode: XMLNode?) -> [TrackPoint] {
        guard let node = segmentNode else {
            return []
        }
        var trackPoints = node.childrenOfType(.trackPoint).compactMap(TrackPoint.init)
        checkForInvalidElevationAtStartAndEnd(trackPoints: &trackPoints)
        return correctElevationGaps(trackPoints: trackPoints)
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
                    temperature: $0.temperature
                )
            }
    }

    private func parseRoute(_ routeNode: XMLNode?) -> [TrackPoint] {
        guard let node = routeNode else {
            return []
        }
        var trackPoints = node.childrenOfType(.routePoint).compactMap(TrackPoint.init)
        checkForInvalidElevationAtStartAndEnd(trackPoints: &trackPoints)
        return correctElevationGaps(trackPoints: trackPoints)
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
                    temperature: $0.temperature
                )
            }
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

internal extension Waypoint {
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

internal extension TrackPoint {
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
    }
}

internal extension XMLNode {
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
