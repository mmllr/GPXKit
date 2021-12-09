import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

/// A class for exporting a `GPXTrack` to an xml string.
public final class GPXExporter {
    private lazy var iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = .withInternetDateTime
        return formatter
    }()
    private let track: GPXTrack
    private let exportDate: Bool

    /// Initializes a GPXExporter
    /// - Parameters:
    ///   - track: The `GPXTrack` to export.
    ///   - shouldExportDate: Flag indicating whether it should export the timestamps in the track. Set it to false if you want to omit the values. This would decrease the exported xml's file size and protects privacy. Defaults to true.
    ///
    /// If the track cannot be exported, the resulting `xmlString` property of the exporter is an empty GPX track xml.
    public init(track: GPXTrack, shouldExportDate: Bool = true) {
        self.track = track
        self.exportDate = shouldExportDate
    }

    /// The exported GPX xml string. If a track cannot be exported, the resulting string. If the track cannot be exported, its value is an empty GPX track xml.
    public var xmlString: String {
        return """
        <?xml version="1.0" encoding="UTF-8"?>
        \(GPXTags.gpx.embed(attributes: headerAttributes,
                            [
                                GPXTags.metadata.embed([
                                    metaDataTime,
                                    track.keywords.isEmpty ? "" : GPXTags.keywords.embed(track.keywords.joined(separator: " "))
                                ].joined(separator: "\n")),
                                GPXTags.track.embed([
                                    GPXTags.name.embed(track.title),
                                    GPXTags.description.embed(track.description ?? ""),
                                    trackXML
                                ].joined(separator: "\n"))
                            ].joined(separator: "\n")))
        """
    }

    private var metaDataTime: String {
        guard exportDate, let date = track.date else { return "" }
        return GPXTags.time.embed(iso8601Formatter.string(from: date))
    }

    private var trackXML: String {
        guard !track.trackPoints.isEmpty else { return "" }
        return GPXTags.trackSegment.embed(
            track.trackPoints.map { point in
                let attributes = [
                    GPXAttributes.latitude.assign("\"\(point.coordinate.latitude)\""),
                    GPXAttributes.longitude.assign("\"\(point.coordinate.longitude)\"")
                ].joined(separator: " ")
                let childs = [GPXTags.elevation.embed(String(format:"%.2f", point.coordinate.elevation)),
                              exportDate ? point.date.flatMap {
                                GPXTags.time.embed(iso8601Formatter.string(from: $0))
                              } : nil
                ].compactMap { $0 }.joined(separator: "\n")
                return GPXTags.trackPoint.embed(
                        attributes: attributes,
                    childs
                )
            }.joined(separator: "\n")
        )
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
