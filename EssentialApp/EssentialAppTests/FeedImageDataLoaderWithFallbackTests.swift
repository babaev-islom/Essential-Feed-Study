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
    
    private final class TaskWrapper: FeedImageDataLoaderTask {
        private var completion: ((FeedImageDataLoader.Result) -> Void)?
        
        init(_ completion: @escaping (FeedImageDataLoader.Result) -> Void) {
            self.completion = completion
        }
        
        var wrapped: FeedImageDataLoaderTask?
        
        func complete(with result: FeedImageDataLoader.Result) {
            completion?(result)
        }
        
        func cancel() {
            wrapped?.cancel()
            preventFurtherCompletions()
        }
        
        private func preventFurtherCompletions() {
            completion = nil
        }
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = TaskWrapper(completion)
        task.wrapped = primary.loadImageData(from: url) { [weak self] result in
            switch result {
            case .success:
                task.complete(with: result)
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

        expect(sut, toCompleteWith: .success(primaryData))
    }
    
    func test_loadImageData_deliversFallbackImageDataOnPrimaryLoaderFailure() {
        let fallbackData = Data("primary".utf8)
        let sut = makeSUT(primaryResult: .failure(anyNSError()), fallbackResult: .success(fallbackData))
        
        expect(sut, toCompleteWith: .success(fallbackData))
    }
    
    func test_loadImageData_deliversErrorOnBothPrimaryAndFallbackLoaderFailure() {
        let sut = makeSUT(primaryResult: .failure(anyNSError()), fallbackResult: .failure(anyNSError()))
        
        expect(sut, toCompleteWith: .failure(anyNSError()))
    }
    
    func test_cancelLoadImageData_cancelsPrimaryLoaderTask() {
        let primaryLoader = ImageLoaderSpy()
        let fallbackLoader = ImageLoaderSpy()
        let sut = FeedImageDataLoaderWithFallback(primary: primaryLoader, fallback: fallbackLoader)
        
        var receivedResults = [FeedImageDataLoader.Result]()
        let task = sut.loadImageData(from: anyURL()) { receivedResults.append($0)}
        task.cancel()
        
        primaryLoader.completeSuccessfully()
        
        XCTAssertTrue(receivedResults.isEmpty)
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
    
    private func expect(_ sut: FeedImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for image data load")
        _ = sut.loadImageData(from: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
                
            case (.failure, .failure):
                break
                
            default:
                XCTFail("Expected to receive \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
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
    
    private class ImageLoaderSpy: FeedImageDataLoader {
        
        private(set) var cancelledURLs = [URL]()
        
        private struct TaskSpy: FeedImageDataLoaderTask {
            let callback: () -> Void
            
            func cancel() {
                callback()
            }
        }
        
        private var completions = [(FeedImageDataLoader.Result) -> Void]()
        
        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            completions.append(completion)
            return TaskSpy { [weak self] in self?.cancelledURLs.append(url) }
        }
        
        func completeSuccessfully(at index: Int = 0) {
            let anyData = Data("any".utf8)
            completions[index](.success(anyData))
        }
    }
}
