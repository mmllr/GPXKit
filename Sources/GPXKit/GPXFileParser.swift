import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

/// Error descringing export erros
public enum GPXParserError: Error, Equatable {
    /// The provided xml contains no valid GPX.
	case invalidGPX
    // No tracks where found in the provided GPX xml.
	case noTracksFound
    /// The provided xml could not be parsed. Contains the underlying NSError from the XMLParser along with the xml files line number where the error occured.
    case parseError(NSError, Int)
}

internal enum GPXTags: String {
	case gpx
	case metadata
	case time
	case track = "trk"
	case name
	case trackPoint = "trkpt"
	case trackSegment = "trkseg"
	case elevation = "ele"
	case extensions
	case power
}

internal enum GPXAttributes: String {
	case latitude = "lat"
	case longitude = "lon"
}

/// Class for importing a GPX xml to an `GPXTrack` value.
final public class GPXFileParser {
	private let xml: String

    /// Initializer
    /// - Parameter xmlString: The GPX xml string. See [GPX specification for details](https://www.topografix.com/gpx.asp).
	public init(xmlString: String) {
		self.xml = xmlString
	}

    /// Parses the GPX xml.
    /// - Returns: A `Result` of the `GPXTrack` in the success or an `GPXParserError` in the failure case.
	public func parse() -> Result<GPXTrack, GPXParserError> {
		let parser = BasicXMLParser(xml: xml)
		switch parser.parse() {
		case let .success(root):
			guard let track = parseRoot(node: root) else { return .failure(.noTracksFound) }
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

	private func parseRoot(node: XMLNode) -> GPXTrack? {
		guard let trackNode = node.childFor(.track),
			let title = trackNode.childFor(.name)?.content else { return nil }
		return GPXTrack(date: node.childFor(.metadata)?.childFor(.time)?.date, title: title, trackPoints: parseSegment(trackNode.childFor(.trackSegment)))
	}

	private func parseMetaData(_ node: XMLNode) -> Date? {
		return node.childFor(.time)?.date
	}

	private func parseSegment(_ segmentNode: XMLNode?) -> [TrackPoint] {
		guard let node = segmentNode else { return [] }
		return node.childrenOfType(.trackPoint).compactMap(TrackPoint.init)
	}
}

internal extension TrackPoint {
	init?(trackNode: XMLNode) {
		guard let lat = trackNode.latitude,
			let lon = trackNode.longitude,
			let ele = trackNode.childFor(.elevation)?.elevation else { return nil }
		self.coordinate = Coordinate(latitude: lat, longitude: lon, elevation: ele)
		self.date = trackNode.childFor(.time)?.date
		self.power = trackNode.childFor(.extensions)?.childFor(.power)?.power
	}
}

internal extension XMLNode {
	static var iso8601Formatter: ISO8601DateFormatter = {
		let formatter = ISO8601DateFormatter()
		formatter.formatOptions = .withInternetDateTime
		return formatter
	}()

	var latitude: Double? {
		Double(atttributes[GPXAttributes.latitude.rawValue] ?? "")
	}
	var longitude: Double? {
		Double(atttributes[GPXAttributes.longitude.rawValue] ?? "")
	}
	var elevation: Double? {
		Double(content)
	}
	var date: Date? {
		XMLNode.iso8601Formatter.date(from: content)
	}
	var power: Measurement<UnitPower>? {
		Double(content).flatMap { Measurement<UnitPower>(value: $0, unit: .watts) }
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
