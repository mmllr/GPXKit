import Foundation
#if canImport(Combine)
import Combine

@available(iOS 13, macOS 10.15, watchOS 6, tvOS 13, *)

extension GPXFileParser {
    public var publisher: AnyPublisher<GPXTrack, GPXParserError> {
        Future { promise in
            promise(self.parse())
        }.eraseToAnyPublisher()
    }

    public class func load(from url: URL) -> AnyPublisher<GPXTrack, GPXParserError> {
        guard let parser = GPXFileParser(url: url) else { return Fail(error: GPXParserError.invalidGPX).eraseToAnyPublisher() }
        return parser.publisher
    }

    public class func load(from data: Data) -> AnyPublisher<GPXTrack, GPXParserError> {
        guard let parser = GPXFileParser(data: data) else { return Fail(error: GPXParserError.invalidGPX).eraseToAnyPublisher() }
        return parser.publisher
    }
}

#endif
