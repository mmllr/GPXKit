import XCTest
import Foundation
import GPXKit
#if canImport(Combine)
import Combine

@available(iOS 13, macOS 10.15, watchOS 6, tvOS 13, *)
final class CombineExtensionTests: XCTestCase {

    func testLoadFromPublisher() throws {
        let sut = GPXFileParser(xmlString: testXMLWithoutExtensions)
        let expectation = self.expectation(description: "publisher")

        let cancellable = sut.publisher
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case let .failure(error):
                    XCTFail(error.localizedDescription)
                }
                expectation.fulfill()
            } receiveValue: { track in
                self.assertTracksAreEqual(testTrack, track)
            }

        wait(for: [expectation], timeout: 10)
        XCTAssertNotNil(cancellable)
    }

    func testLoadFromDataFactoryMethod() throws {
        let expectation = self.expectation(description: "publisher")
        let cancellable = GPXFileParser.load(from: testXMLWithoutExtensions.data(using: .utf8)!)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case let .failure(error):
                    XCTFail(error.localizedDescription)
                }
                expectation.fulfill()
            } receiveValue: { track in
                self.assertTracksAreEqual(testTrack, track)
            }

        wait(for: [expectation], timeout: 10)
        XCTAssertNotNil(cancellable)
    }
}

#endif
