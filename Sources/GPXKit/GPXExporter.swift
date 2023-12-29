import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

/// A class for exporting a `GPX` to an xml string.
public final class GPXExporter {
    private let gpx: GPX
    private let exportDate: Bool

    /// Initializes a GPXExporter
    /// - Parameters:
    ///   - gpx: The ``GPX`` to export.
    ///   - shouldExportDate: Flag indicating whether it should export the timestamps in the track. Set it to false if you want to omit the values. This would decrease the exported xml's file size and protects privacy. Defaults to true.
    ///
    /// If the track cannot be exported, the resulting ``GPXExporter/xmlString`` property of the exporter is an empty GPX track xml.
    public init(track: GPX, shouldExportDate: Bool = true) {
        self.gpx = track
        self.exportDate = shouldExportDate
    }

    /// The exported GPX xml string. If the track cannot be exported, its value is an empty GPX track xml.
    public var xmlString: String {
        return """
        <?xml version="1.0" encoding="UTF-8"?>
        \(GPXTags.gpx.embed(attributes: headerAttributes,
            [
                GPXTags.metadata.embed([
                    metaDataTime,
                    gpx.keywords.isEmpty ? "" : GPXTags.keywords.embed(gpx.keywords.joined(separator: " "))
                ].joined(separator: "\n")),
                waypointsXML,
                tracksXML,
            ].joined(separator: "\n")))
        """
    }

    private var metaDataTime: String {
        guard exportDate, let date = gpx.date else { return "" }
        return GPXTags.time.embed(ISO8601DateFormatter.exporting.string(from: date))
    }

    private var waypointsXML: String {
        guard let waypoints = gpx.waypoints, !waypoints.isEmpty else { return "" }
        return waypoints.map { waypoint in
            let attributes = [
                GPXAttributes.latitude.assign("\"\(waypoint.coordinate.latitude)\""),
                GPXAttributes.longitude.assign("\"\(waypoint.coordinate.longitude)\"")
            ].joined(separator: " ")
            var children = [String]()
            if let name = waypoint.name {
                children.append(GPXTags.name.embed(name))
            }
            if let comment = waypoint.comment {
                children.append(GPXTags.comment.embed(comment))
            }
            if let description = waypoint.description {
                children.append(GPXTags.description.embed(description))
            }
            return GPXTags.waypoint.embed(attributes: attributes, children.joined(separator: "\n"))
        }.joined(separator: "\n")
    }

    private var tracksXML: String {
        return gpx.tracks.map { track in
            return GPXTags.track.embed([
                GPXTags.name.embed(gpx.title),
                gpx.description.flatMap { GPXTags.description.embed( $0) } ?? "",
                
                track.trackSegments.map { segment in
                    return GPXTags.trackSegment.embed([

                        segment.trackPoints.map { point in
                            let attributes = [
                                GPXAttributes.latitude.assign("\"\(point.coordinate.latitude)\""),
                                GPXAttributes.longitude.assign("\"\(point.coordinate.longitude)\"")
                            ].joined(separator: " ")
                            let children = [GPXTags.elevation.embed(String(format:"%.2f", point.coordinate.elevation)),
                                          exportDate ? point.date.flatMap {
                                GPXTags.time.embed(ISO8601DateFormatter.exporting.string(from: $0))
                            } : nil
                            ].compactMap { $0 }.joined(separator: "\n")
                            return GPXTags.trackPoint.embed(
                                attributes: attributes,
                                children
                            )
                        }.joined(separator: "\n")

                    ].joined(separator: "\n"))
                }.joined(separator: "\n")

            ].joined(separator: "\n"))
        }.joined(separator: "\n")
    }
    
    private var headerAttributes: String {
        return """
            creator="GPXKit" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd http://www.garmin.com/xmlschemas/GpxExtensions/v3 http://www.garmin.com/xmlschemas/GpxExtensionsv3.xsd http://www.garmin.com/xmlschemas/TrackPointExtension/v1 http://www.garmin.com/xmlschemas/TrackPointExtensionv1.xsd" version="1.1" xmlns="http://www.topografix.com/GPX/1/1" xmlns:gpxtpx="http://www.garmin.com/xmlschemas/TrackPointExtension/v1" xmlns:gpxx="http://www.garmin.com/xmlschemas/GpxExtensions/v3"
            """
    }
}

extension GPXTags {
    func embed(attributes: String = "", _ content: String) -> String {
        let openTag = ["\(rawValue)", attributes]
            .joined(separator: " ")
            .trimmingCharacters(in: .whitespaces)
        return "<\(openTag)>\n\(content)\n</\(rawValue)>"
    }
}

extension GPXAttributes {
    func assign(_ content: String) -> String {
        "\(rawValue)=\(content)"
    }
}
