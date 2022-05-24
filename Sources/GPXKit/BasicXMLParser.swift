import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

extension String {
    static let trackPointExtensionURL: Self = "http://www.garmin.com/xmlschemas/TrackPointExtension/v1"
}

public struct XMLNode: Equatable, Hashable {
    var name: String
    var attributes: [String: String] = [:]
    var content: String = ""
    public var children: [XMLNode] = []
}

public enum BasicXMLParserError: Error, Equatable {
    case noContent
    case parseError(NSError, Int)
}

public class BasicXMLParser: NSObject, XMLParserDelegate {
    private let parser: XMLParser
    private var resultStack: [XMLNode] = [XMLNode(name: "", attributes: [:], content: "", children: [])]
    private var result: XMLNode? {
        return resultStack.first?.children.first
    }
    private var prefixes: Set<String> = []

    public init(xml: String) {
        parser = XMLParser(data: xml.data(using: .utf8) ?? Data())
        parser.shouldReportNamespacePrefixes = true
    }

    public func parse() -> Result<XMLNode, BasicXMLParserError> {
        parser.delegate = self
        let parseResult = autoreleasepool {
            self.parser.parse()
        }
        if parseResult {
            guard let result = result else { return .failure(.noContent) }
            return .success(result)
        } else {
            let error = BasicXMLParserError.parseError(parser.parserError! as NSError, parser.lineNumber)
            return .failure(error)
        }
    }

    // swiftlint:disable:next line_length
    public func parser(_: XMLParser, didStartElement elementName: String, namespaceURI _: String?, qualifiedName _: String?, attributes attributeDict: [String: String] = [:]) {

        var name: String = elementName
        for pref in prefixes {
            if name.hasPrefix(pref) {
                name.removeFirst(pref.count + 1)
                break
            }
        }

        let newNode = XMLNode(name: name, attributes: attributeDict, content: "", children: [])
        resultStack.append(newNode)
    }

    public func parser(_: XMLParser, didEndElement _: String, namespaceURI _: String?, qualifiedName _: String?) {
        resultStack[resultStack.count - 2].children.append(resultStack.last!)
        resultStack.removeLast()
    }

    public func parser(_: XMLParser, foundCharacters string: String) {
		let contentSoFar = resultStack.last?.content ?? ""
		resultStack[resultStack.count - 1].content = contentSoFar + string.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    public func parser(_ parser: XMLParser,
                         parseErrorOccurred parseError: Error) {
        print(parseError.localizedDescription)
    }

    public func parser(_ parser: XMLParser,
    didStartMappingPrefix prefix: String,
                         toURI namespaceURI: String) {
        guard !prefix.isEmpty else { return }
        if namespaceURI == .trackPointExtensionURL {
            prefixes.insert(prefix)
        }
    }
}
