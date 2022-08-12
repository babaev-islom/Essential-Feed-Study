//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Islom Babaev on 12/08/22.
//

import XCTest

final class FeedViewController {
    init(loader: FeedViewControllerTests.LoaderSpy) {
        
    }
}

final class FeedViewControllerTests: XCTestCase {
    
    func test_init_doesNotLoadFeed() {
        let loader = LoaderSpy()
        _ = FeedViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    
    
    class LoaderSpy {
        private(set) var loadCallCount = 0
    }
}
