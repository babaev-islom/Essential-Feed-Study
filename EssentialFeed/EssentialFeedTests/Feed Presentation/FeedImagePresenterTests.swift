//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Islom Babaev on 22/08/22.
//

import XCTest

final class FeedImagePresenter {
    init(view: Any) {}
}

final class FeedImagePresenterTests: XCTestCase {
    
    func test_init_doesNotMessageViewsUponCreation() {
        let view = ViewSpy()
        
        _ = FeedImagePresenter(view: view)
        
        XCTAssertTrue(view.messages.isEmpty)
    }
    
    private final class ViewSpy {
        let messages = [Any]()
    }
}
