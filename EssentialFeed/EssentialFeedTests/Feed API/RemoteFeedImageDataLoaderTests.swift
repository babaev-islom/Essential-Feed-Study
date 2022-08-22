//
//  RemoteFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Islom Babaev on 22/08/22.
//

import XCTest
import EssentialFeed


final class RemoteFeedImageDataLoader {
    private let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    private struct Task: FeedImageDataLoaderTask {
        private let wrapped: HTTPClientTask
        
        init(_ wrapped: HTTPClientTask) {
            self.wrapped = wrapped
        }
        
        func cancel() {
            wrapped.cancel()
        }
    }
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
        
    @discardableResult
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case .failure:
                completion(.failure(Error.connectivity))
            case let .success((data, response)):
                guard response.statusCode == 200, !data.isEmpty else {
                    return completion(.failure(Error.invalidData))
                }
                completion(.success(data))
            }
        }
        return Task(task)
    }
}

final class RemoteFeedImageDataLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestImageDataLoad() {
        let (_, client) = makeSUT()
        
        XCTAssertEqual(client.requestedURLs, [])
    }
    
    func test_loadImageDataTwice_requestsImageDataLoadFromURLTwice() {
        let anyURL = anyURL()
        let (sut, client) = makeSUT()
        
        sut.loadImageData(from: anyURL) { _ in }
        sut.loadImageData(from: anyURL) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [anyURL, anyURL])
    }
    
    func test_loadImageData_deliversConnectivityErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: failure(.connectivity), when: {
            client.complete(with: anyNSError())
        })
    }
    
    func test_loadImageData_deliversInvalidDataErrorOnClientSuccessWithNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        let samples = [199, 201, 202, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                client.complete(withStatusCode: code, data: Data(), at: index)
            })
        }
    }
    
    func test_loadImageData_deliversInvalidDataOnClientSuccessWith200HTTPResponseWithEmptyData() {
        let emptyData = Data()
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: failure(.invalidData), when: {
            client.complete(withStatusCode: 200, data: emptyData)
        })
    }
    
    func test_loadImageData_deliversDataOnClientSuccessWith200HTTPResponseWithNonEmptyData() {
        let anyData = anyData()
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .success(anyData), when: {
            client.complete(withStatusCode: 200, data: anyData)
        })
    }
    
    func test_cancelLoadImageDataURLTask_cancelsClientURLRequest() {
        let anyURL = anyURL()
        let (sut, client) = makeSUT()
        
        let task = sut.loadImageData(from: anyURL) { _ in }
        XCTAssertTrue(client.cancelledURLs.isEmpty, "Expeceted no cancelled URL request until task is cancelled")
        
        task.cancel()
        XCTAssertEqual(client.cancelledURLs, [anyURL], "Expected cancelled URL request after task is cancelled")
    }
    
    func test_loadImageData_doesNotDeliverResultWhenSUTInstanceHasBeenDeallocated() {
        let client = HTTPClientSpy()
        var sut: RemoteFeedImageDataLoader? = RemoteFeedImageDataLoader(client: client)
        
        var receivedResults: FeedImageDataLoader.Result?
        sut?.loadImageData(from: anyURL()) { receivedResults = $0 }
        
        sut = nil
        client.complete(with: anyNSError())
        
        XCTAssertNil(receivedResults)
    }
    
    //MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedImageDataLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, client)
    }
    
    private func failure(_ error: RemoteFeedImageDataLoader.Error) -> FeedImageDataLoader.Result {
        .failure(error)
    }
    
    private func expect(_ sut: RemoteFeedImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for image data load")
        
        sut.loadImageData(from: anyURL()) { receviedResult in
            switch (receviedResult, expectedResult) {
            case let (.failure(receivedError as RemoteFeedImageDataLoader.Error), .failure(expectedError as RemoteFeedImageDataLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
            default:
                XCTFail("Expected to receive \(expectedResult), got \(receviedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 0.1)
    }
}
