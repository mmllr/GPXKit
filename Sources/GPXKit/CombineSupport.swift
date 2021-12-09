import Foundation
#if canImport(Combine)
import Combine

@available(iOS 13, macOS 10.15, watchOS 6, tvOS 13, *)
extension GPXFileParser {
    /// Publisher for bridging into Combine.
    ///
    /// An AnyPublisher with Output `GPXTrack` and Failure of `GPXParserError`.
    public var publisher: AnyPublisher<GPXTrack, GPXParserError> {
        Future { promise in
            promise(self.parse())
        }.eraseToAnyPublisher()
    }

    /// Helper for loading a gpx track from an url.
    /// - Parameter url: The url of the GPX file. See [GPX specification for details](https://www.topografix.com/gpx.asp).
    /// - Returns: An AnyPublisher with Output `GPXTrack` and Failure of `GPXParserError`.
    ///
    /// ```swift
    /// let url = // ... url with GPX file
    /// GPXFileParser
    ///    .load(from: url)
    ///    .map { track in
    ///         // do something with track
    ///    }
    ///    .catch {
    ///        /// handle parsing error
    ///    }
    /// ```
    public class func load(from url: URL) -> AnyPublisher<GPXTrack, GPXParserError> {
        guard let parser = GPXFileParser(url: url) else { return Fail(error: GPXParserError.invalidGPX).eraseToAnyPublisher() }
        return parser.publisher
    }

    /// Helper for loading a gpx track from data.
    /// - Parameter data: The data containing the GPX as xml. See [GPX specification for details](https://www.topografix.com/gpx.asp).
    /// - Returns: An AnyPublisher with Output `GPXTrack` and Failure of `GPXParserError`.
    ///
    /// ```swift
    /// let data = xmlString.data(using: .utf8)
    /// GPXFileParser
    ///    .load(from: data)
    ///    .map { track in
    ///         // do something with track
    ///    }
    ///    .catch {
    ///        /// handle parsing error
    ///    }
    /// ```
    public class func load(from data: Data) -> AnyPublisher<GPXTrack, GPXParserError> {
        guard let parser = GPXFileParser(data: data) else { return Fail(error: GPXParserError.invalidGPX).eraseToAnyPublisher() }
        return parser.publisher
    }
}

#endif
