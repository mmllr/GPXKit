//
// GPXKit - MIT License - Copyright © 2025 Markus Müller. All rights reserved.
//

import Foundation
import GPXKit
import Testing
#if canImport(Combine)
import Combine

@Suite
struct CombineExtensionTests {
    @Test
    @available(iOS 13, macOS 10.15, watchOS 6, tvOS 13, *)
    func testLoadFromPublisher() async throws {
        await confirmation("publisher") { conf in
            let sut = GPXFileParser(xmlString: testXMLWithoutExtensions)

            let cancellable = sut.publisher
                .sink { completion in
                    switch completion {
                    case .finished:
                        break
                    case let .failure(error):
                        Issue.record(error)
                    }
                    conf()
                } receiveValue: { track in
                    assertTracksAreEqual(testTrack, track)
                }
        }
    }

    @Test
    @available(iOS 13, macOS 10.15, watchOS 6, tvOS 13, *)
    func testLoadFromDataFactoryMethod() async throws {
        await confirmation("data factory method") { conf in
            let cancellable = GPXFileParser.load(from: testXMLWithoutExtensions.data(using: .utf8)!)
                .sink { completion in
                    switch completion {
                    case .finished:
                        break
                    case let .failure(error):
                        Issue.record(error)
                    }
                    conf()
                } receiveValue: { track in
                    assertTracksAreEqual(testTrack, track)
                }
        }
    }
}

#endif
