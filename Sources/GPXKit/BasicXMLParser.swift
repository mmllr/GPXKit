import Foundation

public struct XMLNode: Equatable, Hashable {
    var name: String
    var atttributes: [String: String] = [:]
    var content: String = ""
    public var children: [XMLNode] = []
}

public enum BasicXMLParserError: Error {
    case noContent
    case parseError(NSError)
}

public class BasicXMLParser: NSObject, XMLParserDelegate {
    private let parser: XMLParser
    private var resultStack: [XMLNode] = [XMLNode(name: "", atttributes: [:], content: "", children: [])]
    private var result: XMLNode? {
        return resultStack.first?.children.first
    }

    public init(xml: String) {
        parser = XMLParser(data: xml.data(using: .utf8)!)
    }

    public func parse() -> Result<XMLNode, BasicXMLParserError> {
        parser.delegate = self
        if parser.parse() {
            guard let result = result else { return .failure(.noContent) }
            return .success(result)
        } else {
            let error = BasicXMLParserError.parseError(parser.parserError! as NSError)
            return .failure(error)
        }
    }

    // swiftlint:disable:next line_length
    public func parser(_: XMLParser, didStartElement elementName: String, namespaceURI _: String?, qualifiedName _: String?, attributes attributeDict: [String: String] = [:]) {
        let newNode = XMLNode(name: elementName, atttributes: attributeDict, content: "", children: [])
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
}
