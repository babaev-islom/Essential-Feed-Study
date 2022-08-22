//
//  RemoteFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Islom Babaev on 22/08/22.
//

import XCTest
import EssentialFeed

protocol HTTPLoaderTask {
    func cancel()
}

protocol HTTPLoader {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    func get(from url: URL, completion: @escaping (Result) -> Void) -> HTTPLoaderTask
}

final class RemoteFeedImageDataLoader {
    private let client: HTTPLoader
    
    init(client: HTTPLoader) {
        self.client = client
    }
    
    private struct Task: FeedImageDataLoaderTask {
        private let wrapped: HTTPLoaderTask
        
        init(_ wrapped: HTTPLoaderTask) {
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
        
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = client.get(from: url) { result in
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
        
        _ = sut.loadImageData(from: anyURL) { _ in }
        _ = sut.loadImageData(from: anyURL) { _ in }
        
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
                client.complete(data: Data(), withStatusCode: code, at: index)
            })
        }
    }
    
    func test_loadImageData_deliversInvalidDataOnClientSuccessWith200HTTPResponseWithEmptyData() {
        let emptyData = Data()
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: failure(.invalidData), when: {
            client.complete(data: emptyData, withStatusCode: 200)
        })
    }
    
    func test_loadImageData_deliversDataOnClientSuccessWith200HTTPResponse() {
        let anyData = Data("any".utf8)
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .success(anyData), when: {
            client.complete(data: anyData, withStatusCode: 200)
        })
    }
    
    func test_loadImageData_doesNotCancelTaskUponRequest() {
        let (sut, client) = makeSUT()
        
        _ = sut.loadImageData(from: anyURL()) { _ in }
        
        XCTAssertTrue(client.cancelledURLs.isEmpty)
    }
    
    func test_loadImageData_cancelsImageDataLoadRequest() {
        let anyURL = anyURL()
        let (sut, client) = makeSUT()
        
        let task = sut.loadImageData(from: anyURL) { _ in }
        
        task.cancel()
        XCTAssertEqual(client.cancelledURLs, [anyURL])
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
        
        _ = sut.loadImageData(from: anyURL()) { receviedResult in
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
    
    private class HTTPClientSpy: HTTPLoader {
        private var messages = [(url: URL, completion: (HTTPLoader.Result) -> Void)]()
        var requestedURLs: [URL] {
            messages.map(\.url)
        }
        
        private(set) var cancelledURLs = [URL]()
        
        private struct TaskSpy: HTTPLoaderTask {
            let callback: () -> Void
            
            func cancel() {
                callback()
            }
        }
        
        func get(from url: URL, completion: @escaping (HTTPLoader.Result) -> Void) -> HTTPLoaderTask {
            messages.append((url, completion))
            return TaskSpy { [weak self] in self?.cancelledURLs.append(url) }
        }
        
        func complete(with error: NSError, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(data: Data, withStatusCode code: Int, at index: Int = 0) {
            let message = messages[index]
            let url = message.url
            let response = HTTPURLResponse(url: url, statusCode: code, httpVersion: nil, headerFields: nil)!
            message.completion(.success((data, response)))
        }
    }
}
