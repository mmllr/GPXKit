import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

public final class GPXExporter {
    private lazy var iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = .withInternetDateTime
        return formatter
    }()
    private let track: GPXTrack
    private let exportDate: Bool

    public init(track: GPXTrack, shouldExportDate: Bool = true) {
        self.track = track
        self.exportDate = shouldExportDate
    }

    public var xmlString: String {
        return """
        <?xml version="1.0" encoding="UTF-8"?>
        \(GPXTags.gpx.embed(attributes: headerAttributes,
                            [
                                GPXTags.metadata.embed(metaData),
                                GPXTags.track.embed([
                                    GPXTags.name.embed(track.title),
                                    trackXML
                                ].joined(separator: "\n"))
                            ].joined(separator: "\n")))
        """
    }

    private var metaData: String {
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
                return GPXTags.trackPoint.embed(attributes: attributes,
                                                GPXTags.elevation.embed(String(format:"%.2f", point.coordinate.elevation))
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
        "<\(rawValue) \(attributes)>\n\(content)\n</\(rawValue)>"
    }
}

extension GPXAttributes {
    func assign(_ content: String) -> String {
        "\(rawValue)=\(content)"
    }
}
