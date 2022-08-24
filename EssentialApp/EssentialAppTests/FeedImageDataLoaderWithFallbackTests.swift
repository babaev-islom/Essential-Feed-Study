//
//  FeedImageDataLoaderWithFallbackTests.swift
//  EssentialAppTests
//
//  Created by Islom Babaev on 24/08/22.
//

import XCTest
import EssentialFeed

final class FeedImageDataLoaderWithFallback: FeedImageDataLoader {
    private let primary: FeedImageDataLoader
    
    init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
        self.primary = primary
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = primary.loadImageData(from: url, completion: completion)
        return task
    }
}

final class FeedImageDataLoaderWithFallbackTests: XCTestCase {
    func test_loadImageData_deliversPrimaryImageOnPrimaryLoaderSuccess() {
        let primaryData = Data("primary".utf8)
        let fallbackData = Data("primary".utf8)
        let primaryLoader = ImageLoaderStub(.success(primaryData))
        let fallbackLoader = ImageLoaderStub(.success(fallbackData))
        let sut = FeedImageDataLoaderWithFallback(primary: primaryLoader, fallback: fallbackLoader)
        
        let exp = expectation(description: "Wait for image data load")
        _ = sut.loadImageData(from: anyURL()) { result in
            switch result {
            case let .success(data):
                XCTAssertEqual(data, primaryData)
            default:
                XCTFail("Expected to suceed with \(primaryData), got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func anyURL() -> URL {
        URL(string: "http://any-url.com")!
    }
    
    private class ImageLoaderStub: FeedImageDataLoader {
        private struct TaskSpy: FeedImageDataLoaderTask {
            func cancel() {}
        }
        
        private let result: FeedImageDataLoader.Result
        
        init(_ result: FeedImageDataLoader.Result) {
            self.result = result
        }
        
        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            completion(result)
            return TaskSpy()
        }
    }
}
