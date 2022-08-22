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
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty)
    }
    
    //MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedImagePresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view)
        trackForMemoryLeaks(view)
        trackForMemoryLeaks(sut)
        return (sut, view)
    }
    
    private final class ViewSpy {
        let messages = [Any]()
    }
}
