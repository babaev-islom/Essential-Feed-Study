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
        
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        _ = client.get(from: url) { result in
            
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
    }
}
