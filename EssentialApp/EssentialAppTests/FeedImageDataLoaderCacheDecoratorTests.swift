//
//  FeedImageDataLoaderCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by Islom Babaev on 25/08/22.
//

import XCTest
import EssentialFeed

protocol FeedImageDataCache {
    typealias Result = Swift.Result<Void, Swift.Error>

    func save(_ data: Data, for url: URL, completion: @escaping (Result) -> Void)
}

final class FeedImageDataLoaderCacheDecorator: FeedImageDataLoader {
    private let decoratee: FeedImageDataLoader
    private let cache: FeedImageDataCache
    
    init(decoratee: FeedImageDataLoader, cache: FeedImageDataCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
        
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        decoratee.loadImageData(from: url) { [weak self] result in
            completion(result.map { data in
                self?.cache.save(data, for: url) { _ in }
                return data
            })
        }
    }
}



final class FeedImageDataLoaderCacheDecoratorTests: XCTestCase {
    
    func test_loadImageData_deliversImageDataOnLoaderSuccess() {
        let anyData = anyData()
        let sut = makeSUT(loaderResult: .success(anyData))
        
        expect(sut, toLoad: .success(anyData))
    }
    
    func test_loadImageData_deliversErrorOnLoaderFailure() {
        let sut = makeSUT(loaderResult: .failure(anyNSError()))
        
        expect(sut, toLoad: .failure(anyNSError()))
    }
    
    func test_loadImageData_cachesImageDataOnLoaderSuccess() {
        let data = anyData()
        let url = anyURL()
        let cache = CacheSpy()
        let sut = makeSUT(loaderResult: .success(data), cache: cache)
        
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(cache.messages, [.save(data: data, for: url)], "Expected to cache image data on loader success")
    }
    
    func test_loadImageData_doesNotCacheOnLoaderFailure() {
        let url = anyURL()
        let cache = CacheSpy()
        let sut = makeSUT(loaderResult: .failure(anyNSError()), cache: cache)
        
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertTrue(cache.messages.isEmpty, "Expected no cache on loader failure")
    }
    
    //MARK: - Helpers
    
    private func makeSUT(loaderResult: FeedImageDataLoader.Result, cache: CacheSpy = .init(), file: StaticString = #filePath, line: UInt = #line) -> FeedImageDataLoader {
        let loader = FeedImageDataLoaderStub(result: loaderResult)
        let sut = FeedImageDataLoaderCacheDecorator(decoratee: loader, cache: cache)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func expect(_ sut: FeedImageDataLoader, toLoad expectedResult: FeedImageDataLoaderStub.Result, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for load")
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
        wait(for: [exp], timeout: 0.1)
    }
    
    private func anyData() -> Data {
        Data("any".utf8)
    }
    
    private class CacheSpy: FeedImageDataCache {
        private(set) var messages = [Message]()
        
        enum Message: Equatable {
            case save(data: Data, for: URL)
        }
        
        func save(_ data: Data, for url: URL, completion: @escaping (FeedImageDataCache.Result) -> Void) {
            messages.append(.save(data: data, for: url))
            completion(.success(()))
        }
    }
    
    private class FeedImageDataLoaderStub: FeedImageDataLoader {
        private struct TaskSpy: FeedImageDataLoaderTask {
            func cancel() {}
        }
        
        private let result: FeedImageDataLoader.Result
        
        init(result: FeedImageDataLoader.Result) {
            self.result = result
        }
        
        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            completion(result)
            return TaskSpy()
        }
    }
}
