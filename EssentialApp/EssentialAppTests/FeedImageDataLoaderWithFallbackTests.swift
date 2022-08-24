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
    private let fallback: FeedImageDataLoader
    
    init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = primary.loadImageData(from: url) { [weak self] result in
            switch result {
            case .success:
                completion(result)
            case .failure:
                _ = self?.fallback.loadImageData(from: url, completion: completion)
            }
        }
        return task
    }
}

final class FeedImageDataLoaderWithFallbackTests: XCTestCase {
    func test_loadImageData_deliversPrimaryImageOnPrimaryLoaderSuccess() {
        let primaryData = Data("primary".utf8)
        let fallbackData = Data("primary".utf8)
        let sut = makeSUT(primaryResult: .success(primaryData), fallbackResult: .success(fallbackData))

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
    
    func test_loadImageData_deliversFallbackImageDataOnPrimaryLoaderFailure() {
        let fallbackData = Data("primary".utf8)
        let sut = makeSUT(primaryResult: .failure(anyNSError()), fallbackResult: .success(fallbackData))
        
        let exp = expectation(description: "Wait for image data load")
        _ = sut.loadImageData(from: anyURL()) { result in
            switch result {
            case let .success(data):
                XCTAssertEqual(data, fallbackData)
            default:
                XCTFail("Expected to suceed with \(fallbackData), got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    //MARK: - Helpers
    
    private func makeSUT(primaryResult: FeedImageDataLoader.Result, fallbackResult: FeedImageDataLoader.Result, file: StaticString = #filePath, line: UInt = #line) -> FeedImageDataLoaderWithFallback {
        let primaryLoader = ImageLoaderStub(primaryResult)
        let fallbackLoader = ImageLoaderStub(fallbackResult)
        let sut = FeedImageDataLoaderWithFallback(primary: primaryLoader, fallback: fallbackLoader)
        trackForMemoryLeaks(primaryLoader, file: file, line: line)
        trackForMemoryLeaks(fallbackLoader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak", file: file, line: line)
        }
    }
    
    private func anyURL() -> URL {
        URL(string: "http://any-url.com")!
    }
    
    private func anyNSError() -> NSError {
        NSError(domain: "any error", code: 0)
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
