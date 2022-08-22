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
        func cancel() {
        }
    }
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
        
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        _ = client.get(from: url) { result in
            switch result {
            case .failure:
                completion(.failure(Error.connectivity))
            case let .success(_, response):
                guard response.statusCode == 200 else {
                    return completion(.failure(Error.invalidData))
                }
            }
        }
        return Task()
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
        let exp = expectation(description: "Wait for image data load")
        
        _ = sut.loadImageData(from: anyURL()) { result in
            switch result {
            case let .failure(error as RemoteFeedImageDataLoader.Error):
                XCTAssertEqual(error, .connectivity)
            default:
                XCTFail("Expected to receive connectivity error, got \(result) instead")
            }
            exp.fulfill()
        }
        client.complete(with: anyNSError())
        
        wait(for: [exp], timeout: 0.1)
    }
    
    func test_loadImageData_deliversInvalidDataErrorOnClientSuccessWithNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        let exp = expectation(description: "Wait for image data load")
        
        _ = sut.loadImageData(from: anyURL()) { result in
            switch result {
            case let .failure(error as RemoteFeedImageDataLoader.Error):
                XCTAssertEqual(error, .invalidData)
            default:
                XCTFail("Expected to receive connectivity error, got \(result) instead")
            }
            exp.fulfill()
        }
        client.complete(data: Data(), withStatusCode: 400)
        
        wait(for: [exp], timeout: 0.1)
    }
    
    //MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedImageDataLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPLoader {
        private var messages = [(url: URL, completion: (HTTPLoader.Result) -> Void)]()
        var requestedURLs: [URL] {
            messages.map(\.url)
        }
        
        private struct TaskSpy: HTTPLoaderTask {
            func cancel() {
                
            }
        }
        
        func get(from url: URL, completion: @escaping (HTTPLoader.Result) -> Void) -> HTTPLoaderTask {
            messages.append((url, completion))
            return TaskSpy()
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
