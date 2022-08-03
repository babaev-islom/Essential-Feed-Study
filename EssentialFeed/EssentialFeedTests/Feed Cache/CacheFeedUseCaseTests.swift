//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Islom Babaev on 03/08/22.
//

import XCTest

class LocalFeedLoader {
    init(store: FeedStore) {
        
    }
}

class FeedStore {
    var deleteCachedFeedCallCount = 0
}



final class CacheFeedUseCaseTests: XCTestCase {
    func test_init_doesNotdeleteCacheUponCreation() {
        let store = FeedStore()
        _ = LocalFeedLoader(store: store)
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }
}
