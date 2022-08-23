//
//  LocalFeedImageDataLoader.swift
//  EssentialFeedTests
//
//  Created by Islom Babaev on 23/08/22.
//

import XCTest

final class LocalFeedImageDataLoader {
    init(store: Any) {}
}

final class LocalFeedImageDataLoaderTests: XCTestCase {
    
    func test_init_doesNotMessageStore() {
        let store = FeedImageStoreSpy()
        
        _ = LocalFeedImageDataLoader(store: store)
        
        XCTAssertTrue(store.messages.isEmpty)
    }
    
    private class FeedImageStoreSpy {
        let messages = [Any]()
    }
}
