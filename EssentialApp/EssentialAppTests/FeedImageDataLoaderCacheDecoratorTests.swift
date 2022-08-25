//
//  FeedImageDataLoaderCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by Islom Babaev on 25/08/22.
//

import XCTest
import EssentialFeed

final class FeedImageDataLoaderCacheDecorator: FeedImageDataLoader {
    private let decoratee: FeedImageDataLoader
    
    init(decoratee: FeedImageDataLoader) {
        self.decoratee = decoratee
    }
        
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        decoratee.loadImageData(from: url, completion: completion)
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

    
    //MARK: - Helpers
    
    private func makeSUT(loaderResult: FeedImageDataLoader.Result, file: StaticString = #filePath, line: UInt = #line) -> FeedImageDataLoader {
        let loader = FeedImageDataLoaderStub(result: loaderResult)
        let sut = FeedImageDataLoaderCacheDecorator(decoratee: loader)
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
