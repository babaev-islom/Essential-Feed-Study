//
//  LocalFeedImageDataLoader.swift
//  EssentialFeedTests
//
//  Created by Islom Babaev on 23/08/22.
//

import XCTest
import EssentialFeed

final class LocalFeedImageDataLoader {
    private let store: LocalFeedImageDataLoaderTests.FeedImageStoreSpy
    init(store: LocalFeedImageDataLoaderTests.FeedImageStoreSpy) {
        self.store = store
    }
    
    private struct Task: FeedImageDataLoaderTask {
        func cancel() {}
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        store.retrieve(dataForURL: url) { result in
            switch result {
            case let .failure(error):
                completion(.failure(error))
            default: break
            }
        }
        
        return Task()
    }
}

final class LocalFeedImageDataLoaderTests: XCTestCase {
    
    func test_init_doesNotMessageStore() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.messages.isEmpty)
    }
    
    func test_loadImageDataTwice_requestsDataLoadFromStoreTwice() {
        let url = anyURL()
        let (sut, store) = makeSUT()

        _ = sut.loadImageData(from: url) { _ in }
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(store.messages, [.retrieve(dataFor: url), .retrieve(dataFor: url)])
    }
    
    func test_loadImageData_deliversErrorOnStoreFailure() {
        let anyNSError = anyNSError()
        let (sut, store) = makeSUT()
        let exp = expectation(description: "Wait for load image data")
        
        _ = sut.loadImageData(from: anyURL()) { result in
            switch result {
            case let .failure(error as NSError):
                XCTAssertEqual(error, anyNSError)
            default:
                XCTFail("Expected to receive \(anyNSError), got \(result) instead")
            }
            exp.fulfill()
        }
        store.completeRetrieval(with: anyNSError)
        
        wait(for: [exp], timeout: 0.1)
    }
    
    //MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: FeedImageStoreSpy) {
        let store = FeedImageStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    class FeedImageStoreSpy {
        enum Message: Equatable {
            case retrieve(dataFor: URL)
        }
        
        private(set) var messages = [Message]()
        private var retrievalRequests = [(url: URL, completion: (Result<Data,Error>) -> Void)]()
        
        func retrieve(dataForURL url: URL, completion: @escaping (Result<Data,Error>) -> Void) {
            messages.append(.retrieve(dataFor: url))
            retrievalRequests.append((url, completion))
        }
        
        func completeRetrieval(with error: Error, at index: Int = 0) {
            retrievalRequests[index].completion(.failure(error))
        }
    }
}
