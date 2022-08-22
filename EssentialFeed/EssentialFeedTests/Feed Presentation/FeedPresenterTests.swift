//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Islom Babaev on 22/08/22.
//

import XCTest

class FeedPresenter {
    init(view: Any) {
        
    }
}


class FeedPresenterTests: XCTestCase {
    
    func test_init_doesNotSendMessagesToView() {
        let view = ViewSpy()
        
        _ = FeedPresenter(view: view)
        
        XCTAssertTrue(view.messages.isEmpty)
    }
    
    //MARK: - Helpers
    
    private final class ViewSpy {
        let messages = [Any]()
    }
    
}
