//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Islom Babaev on 01/08/22.
//

import XCTest
class RemoteFeedLoader {
    
}

class HTTPClient {
    var requestedURL: URL?
}

final class RemoteFeedLoaderTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClient()
        _ = RemoteFeedLoader()
                
        XCTAssertNil(client.requestedURL)
    }
    
}
