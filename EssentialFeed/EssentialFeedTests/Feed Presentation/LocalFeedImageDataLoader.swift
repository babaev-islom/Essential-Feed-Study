//
//  LocalFeedImageDataLoader.swift
//  EssentialFeedTests
//
//  Created by Islom Babaev on 23/08/22.
//

import XCTest
import EssentialFeed




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
    
    func test_loadImageData_failsOnStoreFailure() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: failure(.failed), when: {
            let retrievalError = anyNSError()
            store.completeRetrieval(with: retrievalError)
        })
    }
    
    func test_loadImageData_deliversNotFoundErrorOnNotFoundData() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: failure(.notFound), when: {
            store.complete(with: .none)
        })
    }
    
    func test_loadImageData_deliversStoreData() {
        let foundData = anyData()
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: .success(foundData), when: {
            store.complete(with: foundData)
        })
    }
    
    func test_cancelLoadImageData_doesNotDeliverResult() {
        let (sut, store) = makeSUT()
        let foundData = anyData()
        
        var receivedResults = [FeedImageDataLoader.Result]()
        let task = sut.loadImageData(from: anyURL()) { receivedResults.append($0) }
        task.cancel()
        
        store.complete(with: foundData)
        store.complete(with: .none)
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertTrue(receivedResults.isEmpty, "Expected no received results after cancelling task")
    }
    
    func test_loadImageData_doesNotDeliverREsultAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedImageDataStoreSpy()
        var sut: LocalFeedImageDataLoader? = LocalFeedImageDataLoader(store: store)
        
        var receivedResult: FeedImageDataLoader.Result?
        _ = sut?.loadImageData(from: anyURL()) { receivedResult = $0 }
        
        sut = nil
        store.complete(with: .none)
        
        XCTAssertNil(receivedResult, "Expected no received result after SUT instance has been deallocated")
    }
    
    private func failure(_ error: LocalFeedImageDataLoader.Error) -> FeedImageDataLoader.Result {
        .failure(error)
    }
    
    //MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: FeedImageDataStoreSpy) {
        let store = FeedImageDataStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func expect(_ sut: LocalFeedImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        
        _ = sut.loadImageData(from: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
            
            case let (.failure(receivedError as LocalFeedImageDataLoader.Error), .failure(expectedError as LocalFeedImageDataLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            
            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 0.1)
    }
    
    class FeedImageDataStoreSpy: FeedImageDataStore {
        enum Message: Equatable {
            case retrieve(dataFor: URL)
        }
        
        private(set) var messages = [Message]()
        private var retrievalRequests = [(url: URL, completion: (FeedImageDataStore.Result) -> Void)]()
        
        func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.Result) -> Void) {
            messages.append(.retrieve(dataFor: url))
            retrievalRequests.append((url, completion))
        }
        
        func completeRetrieval(with error: Error, at index: Int = 0) {
            retrievalRequests[index].completion(.failure(error))
        }
        
        func complete(with data: Data?, at index: Int = 0) {
            retrievalRequests[index].completion(.success(data))
        }
    }
}
