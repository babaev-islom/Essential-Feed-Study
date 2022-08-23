//
//  FeedImageDataStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Islom Babaev on 23/08/22.
//

import Foundation
import EssentialFeed

class FeedImageDataStoreSpy: FeedImageDataStore {
    enum Message: Equatable {
        case retrieve(dataFor: URL)
        case insert(data: Data, for: URL)
    }
    
    private(set) var messages = [Message]()
    private var retrievalRequests = [(url: URL, completion: (FeedImageDataStore.RetrievalResult) -> Void)]()
    
    func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
        messages.append(.retrieve(dataFor: url))
        retrievalRequests.append((url, completion))
    }
    
    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievalRequests[index].completion(.failure(error))
    }
    
    func completeRetrieval(with data: Data?, at index: Int = 0) {
        retrievalRequests[index].completion(.success(data))
    }
    
    func insert(_ data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {
        messages.append(.insert(data: data, for: url))
    }
}
