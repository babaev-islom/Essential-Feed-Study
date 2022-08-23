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
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.messages.isEmpty)
    }
    
    //MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: FeedImageStoreSpy) {
        let store = FeedImageStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private class FeedImageStoreSpy {
        let messages = [Any]()
    }
}
