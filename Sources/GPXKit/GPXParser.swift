import Foundation

public struct GPXTrack: Equatable {
	public let date: Date?
	public let title: String
	public let trackPoints: [TrackPoint]
}

public enum GPXParserError: Error {
	case invalidGPX
	case noTracksFound
}

fileprivate enum GPXTags: String {
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

fileprivate enum GPXAttributes: String {
	case latitude = "lat"
	case longitude = "lon"
}

final public class GPXFileParser {
	private let xml: String

	public init(xmlString: String) {
		self.xml = xmlString
	}

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
			case .parseError:
				return .failure(.invalidGPX)
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

fileprivate extension TrackPoint {
	init?(trackNode: XMLNode) {
		guard let lat = trackNode.latitude,
			let lon = trackNode.longitude,
			let ele = trackNode.childFor(.elevation)?.elevation else { return nil }
		self.coordinate = Coordinate(latitude: lat, longitude: lon, elevation: ele)
		self.date = trackNode.childFor(.time)?.date
		self.power = trackNode.childFor(.extensions)?.childFor(.power)?.power
	}
}

private extension XMLNode {
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
