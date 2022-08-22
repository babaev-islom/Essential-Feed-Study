//
//  RemoteFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Islom Babaev on 22/08/22.
//

import XCTest
import EssentialFeed

final class RemoteFeedImageDataLoader {
    init(client: Any) {
        
    }
}

final class RemoteFeedImageDataLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestImageDataLoad() {
        let client = HTTPClientSpy()
        _ = RemoteFeedImageDataLoader(client: client)
        
        XCTAssertEqual(client.requestedURLs, [])
    }
    
    private class HTTPClientSpy {
        let requestedURLs = [URL]()
    }
}
